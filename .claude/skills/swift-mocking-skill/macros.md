## Macros

Swift Mocking contains several Swift macros: `@Mocked`, `@MockedMembers`, `@MockableProperty`, and `@MockableMethod`. 

It also contains two internal, underscored macros (`@_MockedProperty` and `@_MockedMethod`) which are not meant to be used directly.

### `@Mocked`

`@Mocked` is an attached peer macro that generates a mock class from a protocol declaration:
```swift
@Mocked(compilationCondition: .debug)
protocol Dependency {}

// Generates:

#if DEBUG
@MockedMembers
final class DependencyMock: Dependency {}
#endif
```

#### Compilation Condition

Using `@Mocked` without an explicit `compilationCondition` argument will result in the generated mock being wrapped
in an `#if` compiler directive with a `SWIFT_MOCKING_ENABLED` condition:
```swift
@Mocked
protocol Dependency {}

// Generates:

#if SWIFT_MOCKING_ENABLED
@MockedMembers
final class DependencyMock: Dependency {}
#endif
```

Because of the nature of Swift macros, `@Mocked` only has access to the raw syntax of its arguments and the protocol
to which it's attached. This limitation precludes us from making `compilationCondition` globally configurable. So when 
deciding on an appropriate default value for `compilationCondition`, we had two goals in mind:
1. One-step install and one-line usage (excluding import statement) for users who want conditionally compiled,
   generated mocks without any additional setup
2. The simplest setup possible for users with large codebases who want fine-tuned control over when generated mocks
   are compiled

As such, we decided to make the default compilation condition `SWIFT_MOCKING_ENABLED`. This allows us to accomplish
both of these goals, albeit with the tiny caveat that one-step-install users need to explicitly specify the compilation 
condition when using `@Mocked`.

If you would like to make use of `SWIFT_MOCKING_ENABLED` in an Xcode project, add `SWIFT_MOCKING_ENABLED` as a compiler 
flag to the build configurations for which you would like mocks to compile. 

To make use of `SWIFT_MOCKING_ENABLED` in a Swift package, add the following `SwiftSetting` to your target's `swiftSettings`
array:
```swift
.define("SWIFT_MOCKING_ENABLED", .when(configuration: .debug))
```

> [!Note]
> The `.debug` build configuration in a Swift package applies to any Xcode project build configuration with a name
> that begins with either "Debug" or "Development".

If you would like to specify a compilation condition other than `SWIFT_MOCKING_ENABLED`, you can explicitly provide
one to the `@Mocked` macro:
```swift
/// The mock will not be wrapped in an `#if` compiler directive.
@Mocked(compilationCondition: .none)
protocol NoneCompilationCondition {}

/// `#if DEBUG`
@Mocked(compilationCondition: .debug)
protocol DebugCompilationCondition {}

/// `#if !RELEASE`
@Mocked(compilationCondition: "!RELEASE")
protocol CustomCompilationCondition {}
```

#### Sendable Conformance

The `@Mocked` macro supports a `sendableConformance` argument, which
can be `.checked` or `.unchecked`, allowing you to control the
`Sendable` conformance of the generated mock.

With `.checked`, the mock's Sendability is inherited from the protocol it is
mocking, resulting in checked `Sendable` conformance if the protocol inherits
from `Sendable`.
```swift
@Mocked
protocol Dependency: Sendable {}

// Or

@Mocked(sendableConformance: .checked)
protocol Dependency: Sendable {}

// Both generate:

#if SWIFT_MOCKING_ENABLED
@MockedMembers
final class DependencyMock: Dependency {}
#endif
```

With `.unchecked`, the generated mock will explicitly conform to `@unchecked Sendable`.
This is useful when you need your mock to be `Sendable` but cannot satisfy strict
compiler checks and know your usage is concurrency-safe.

```swift
@Mocked(sendableConformance: .unchecked)
protocol Dependency: Sendable {}

// Generates:

#if SWIFT_MOCKING_ENABLED
@MockedMembers
final class DependencyMock: @unchecked Sendable, Dependency {}
#endif
```

#### Access Levels

The generated mock is marked with the access level required to conform to the protocol:
`public` for `public`, implicit `internal` for both implicit and explicit `internal`,
and `fileprivate` for both `fileprivate` and `private`.

#### Actor Conformance

`@Mocked` also supports protocols that conform to `Actor`:
```swift
@Mocked(compilationCondition: .debug)
protocol Dependency: Actor {}

// Generates:

#if DEBUG
@MockedMembers
final actor DependencyMock: Dependency {}
#endif
```

#### Associated Types

When `@Mocked` is applied to a protocol that defines associated types, the resulting mock uses 
those associated types as its generic parameters in order to fulfill the protocol requirements:
```swift
@Mocked(compilationCondition: .debug)
protocol Dependency {
    associatedtype Key: Hashable
    associatedtype Value: Equatable
}

// Generates:

#if DEBUG
@MockedMembers
final class DependencyMock<Key: Hashable, Value: Equatable>: Dependency {}
#endif
```

#### Members

In addition to the `@MockedMembers` macro that gets applied to the mock declaration, `@Mocked` also 
utilizes the `@MockableProperty` and `@MockableMethod` macros when defining the mock's members:
```swift
@Mocked(compilationCondition: .debug)
protocol Dependency {
    var readOnlyProperty: Int { get }
    var readOnlyAsyncProperty: Int { get async }
    var readOnlyThrowingProperty: Int { get throws }
    var readOnlyAsyncThrowingProperty: Int { get async throws }
    var readWriteProperty: Int { get set }
}

// Generates:

#if DEBUG
@MockedMembers
final class DependencyMock: Dependency {
    @MockableProperty(.readOnly)
    var readOnlyProperty: Int

    @MockableProperty(.readOnly(.async))
    var readOnlyAsyncProperty: Int

    @MockableProperty(.readOnly(.throws))
    var readOnlyThrowingProperty: Int

    @MockableProperty(.readOnly(.async, .throws))
    var readOnlyAsyncThrowingProperty: Int

    @MockableProperty(.readWrite)
    var readWriteProperty: Int
}
#endif
```
Because `@MockedMembers` cannot look outward at the protocol declaration to determine whether, for example,
a property is read-only or read-write, `@Mocked` uses `@MockableProperty` and `@MockableMethod` to provide
information about each member to `@MockedMembers`. `@MockedMembers` then applies the `@_MockedProperty` and 
`@_MockedMethod` macros to those members, which then generate the mock's backing properties.

> **Note:** > See [`@Mockable` vs. `@_Mocked`](#mockable-vs-_mocked) for more information.

### `@MockedMembers`

Like `@MockedMembers`, `@Mocked` also cannot look outward. This presents a problem when the protocol you are trying 
to mock inherits from another protocol. Because `@Mocked` cannot see the other protocol's declaration, it is unable 
to generate conformances to the requirements of that protocol. In this instance, you will need to write the mock 
declaration yourself, along with the declarations for the properties and methods required by the protocols. Luckily, 
using Xcode's [Fix-It](https://developer.apple.com/documentation/xcode/fixing-issues-in-your-code-as-you-type#Make-a-Fix-It-correction) 
feature to add protocol conformances and `@MockedMembers`, `@MockableProperty`, and `@MockableMethod` to generate 
backing properties, you can still easily create and maintain these mocks with minimal code:
```swift
protocol Dependency: SomeProtocol {
    var propertyFromDependency: Int { get }

    func methodFromDependency()
}

#if DEBUG
@MockedMembers
final class DependencyMock: Dependency {
    @MockableProperty(.readOnly)
    var propertyFromDependency: Int

    @MockableProperty(.readWrite)
    var propertyFromSomeProtocol: Int

    func methodFromDependency()

    func methodFromSomeProtocol()
}
#endif
```

#### Static Members

When a mock contains static members, `@MockedMembers` generates a static method named `resetMockedStaticMembers`
that can be used to reset the backing properties for those static members:
```swift
@MockedMembers
public final class DependencyMock: Dependency {
    @MockableProperty(.readOnly)
    public static var staticReadOnlyProperty: Int

    @MockableProperty(.readWrite)
    public static var staticReadWriteProperty: Int

    public static func staticMethod()

    // Generates:

    /// Resets the implementations and invocation records of the mock's 
    /// static properties and methods.
    public static func resetMockedStaticMembers() {
        self.__staticReadOnlyProperty.reset()
        self.__staticReadWriteProperty.reset()
        self.__staticMethod.reset()
    }
}
```

This method is useful for tearing down static state between test cases.

### `@MockableProperty`

In instances where you are using `@MockedMembers` directly instead of using `@Mocked`, `@MockableProperty` 
is required for `@MockedMembers` to be able to generate backing properties for the property conformances 
within your mock:
```swift
protocol Dependency {
    var readOnlyProperty: Int { get }
    var readOnlyAsyncProperty: Int { get }
    var readOnlyThrowingProperty: Int { get }
    var readOnlyAsyncThrowingProperty: Int { get }
    var readWriteProperty: Int { get set }
}

#if DEBUG
@MockedMembers
final class DependencyMock: Dependency {
    @MockableProperty(.readOnly)
    var readOnlyProperty: Int { get }

    @MockableProperty(.readOnly(.async))
    var readOnlyAsyncProperty: Int { get }

    @MockableProperty(.readOnly(.throws))
    var readOnlyThrowingProperty: Int { get }

    @MockableProperty(.readOnly(.async, .throws))
    var readOnlyAsyncThrowingProperty: Int { get }

    @MockableProperty(.readWrite)
    var readWriteProperty: Int { get set }
}
#endif
```

### `@MockableMethod`

Unlike `@MockableProperty`, `@MockableMethod` is not required when using `@MockedMembers` directly. 
`@MockedMembers` can and will generate backing properties for method conformances within your mock 
whether they are explicitly marked with `@MockableMethod` or not.

Still, there may be cases where you want or need to use `@MockableMethod`. While `@Mocked` and `@MockedMembers` 
do an excellent job of dealing with name conflicts caused by method overloads, there's always a possibility that 
a name conflict may arise between two backing properties. In this case, you can provide an explicit name for the 
method's backing property using `@MockableMethod`:
```swift
@MockedMembers
final class DependencyMock: Dependency {
    @MockableMethod(mockMethodName: "someUniqueName")
    func methodWithNameConflict()
}
```

In other cases, you may simply dislike the name that `@Mocked` or `@MockedMembers` generates for a 
method's backing property and wish to give the backing property a different name.

If you believe that `@Mocked` or `@MockedMembers` should have been able to resolve a name conflict,
or if you think the name conflict resolution logic can be improved in any way, please let us know by
[opening an issue](https://github.com/fetch-rewards/swift-mocking/issues/new).

### `@Mockable` vs. `@_Mocked`

`@MockableProperty` and `@MockableMethod` do not produce expansions. They are simply markers that expose information
to `@MockedMembers`. `@MockableProperty` exposes `propertyType` (`.readOnly`, `.readWrite`, etc.) and `@MockableMethod`
exposes `mockMethodName`. `@MockedMembers` then forwards this information to `@_MockedProperty` and `@_MockedMethod` along 
with other parameters that `@MockedMembers` provides for us. `@_MockedProperty` and `@_MockedMethod` then generate the mock's 
backing properties. `@MockableProperty` and `@MockableMethod` exist so that the consumer has to provide as little information 
as possible when manually applying `@MockedMembers`. The usage of the prefix `Mockable` is a deliberate choice to semantically 
distinguish the macros that serve as markers from those that actually produce mocks.
