## Usage

Import `Mocking`:
```swift
import Mocking
```

Attach the `@Mocked` macro to your protocol:
```swift
@Mocked(compilationCondition: .debug)
protocol Dependency {
    var property: Int { get set }

    func method(x: Int, y: Int) async throws -> Int
}
```

And that's it! You now have a sophisticated mock dependency that will be updated automatically any time you change 
your protocol.

> **Note:** > For mocking protocols that inherit from other protocols, see [`@MockedMembers`](#mockedmembers).

> **Important:** > Using `@Mocked` without an explicit `compilationCondition` argument will result in the generated mock being wrapped
> in an `#if` compiler directive with a `SWIFT_MOCKING_ENABLED` condition (i.e. `#if SWIFT_MOCKING_ENABLED`). To continue
> using `@Mocked` without any additional setup, use `@Mocked(compilationCondition: .debug)` as shown in the examples above.
> If you would like fine-tuned control over when generated mocks are compiled, see [Compilation Condition](#compilation-condition).

Now let's take a look at the mock we've generated, stripping out some of the implementation details to highlight
the mock's API:
```swift
#if DEBUG
final class DependencyMock: Dependency {
    var property: Int
    var _property: MockReadWriteProperty<Int>

    func method(x: Int, y: Int) async throws -> Int
    var _method: MockReturningParameterizedAsyncThrowingMethod<...>
}
#endif
```

Each member of the generated mock is backed by a single, underscored property. These backing properties contain 
the invocation records and implementation details for each member. 

For example, the backing property for `property` from the above mock would have the following structure and 
implementation constructors:
```swift
// Invocation Records
mock._property.getter.callCount // Int
mock._property.getter.returnedValues // [Int]
mock._property.getter.lastReturnedValue // Int?

mock._property.setter.callCount // Int
mock._property.setter.invocations // [Int]
mock._property.setter.lastInvocation // Int?

// Implementation Constructors
mock._property.getter.implementation = .invokes { 5 }
mock._property.getter.implementation = .uncheckedInvokes { 5 }
mock._property.getter.implementation = .returns(5)
mock._property.getter.implementation = .uncheckedReturns(5)

mock._property.setter.implementation = .invokes { _ in }
mock._property.setter.implementation = .uncheckedInvokes { _ in }
```

And the backing property for `method` from the above mock would have the following structure and implementation
constructors:
```swift
// Invocation Records
mock._method.callCount // Int
mock._method.invocations // [(x: Int, y: Int)]
mock._method.lastInvocation // (x: Int, y: Int)?
mock._method.returnedValues // [Result<Int, any Error>]
mock._method.lastReturnedValue // Result<Int, any Error>?

// Implementation Constructors
mock._method.implementation = .invokes { _, _ in 5 }
mock._method.implementation = .uncheckedInvokes { _, _ in 5 }
mock._method.implementation = .throws(URLError(.badServerResponse))
mock._method.implementation = .returns(5)
mock._method.implementation = .uncheckedReturns(5)
```

> **Note:** > Depending on the type of member being mocked, the backing property's structure and implementation constructors
> may differ slightly from the examples above.

> **Tip:** > Only use `unchecked` implementation constructors when dealing with non-sendable types. For sendable types, use
> the checked version of each implementation constructor (e.g. `invokes` instead of `uncheckedInvokes` and `returns`
> instead of `uncheckedReturns`). These checked constructors require the member's arguments and/or return value to
> be sendable.
>
> With Strict Concurrency Checking or Swift 6+ enabled, you will get concurrency warnings/errors if you try to use
> these checked constructors with a non-sendable type, whether that non-sendable type is the member's argument or
> return value or is a type captured by the closure passed to `invokes`:
> ```swift
> let nonSendableInstance = NonSendableType()
> 
> mock._methodReturningNonSendableType.implementation = .invokes { // Type 'NonSendableType' does not conform to the 'Sendable' protocol
>     nonSendableInstance // Capture of 'nonSendableInstance' with non-sendable type 'NonSendableType' in a `@Sendable` closure
> } 
> ```
