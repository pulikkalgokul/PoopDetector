# Swift Mocking Basics

Complete guide to using the Swift Mocking library for protocol mocking in unit tests.

## Overview

Swift Mocking is a Swift 6-compatible macro library that automatically generates sophisticated mock implementations from protocol declarations for unit testing. It uses Swift macros to generate type-safe, concurrency-safe mocks that eliminate boilerplate test code.

## Basic Usage Pattern

### 1. Apply the Macro

Attach `@Mocked` to a protocol declaration:

```swift
import Mocking

@Mocked(compilationCondition: .debug)
protocol WeatherService {
    func currentTemperature(latitude: Double, longitude: Double) async throws -> Double
}
```

The `compilationCondition` parameter ensures mocks only compile in test/debug builds.

### 2. Use the Generated Mock

The macro generates a mock class named `{Protocol}Mock`:

```swift
import Testing

struct WeatherViewModelTests {
    @Test
    func loadCurrentTemperature() async {
        let weatherServiceMock = WeatherServiceMock()
        let viewModel = WeatherViewModel(weatherService: weatherServiceMock)

        // Configure mock behavior
        weatherServiceMock._currentTemperature.implementation = .returns(75)

        // Execute code under test
        await viewModel.loadCurrentTemperature(latitude: 37.3349, longitude: 122.0090)

        // Verify invocations
        #expect(weatherServiceMock._currentTemperature.callCount == 1)
        #expect(weatherServiceMock._currentTemperature.lastInvocation?.latitude == 37.3349)
        #expect(viewModel.state == .loaded(temperature: 75))
    }
}
```

### 3. Understanding Backing Properties

Each mocked member has an underscored backing property (e.g., `_currentTemperature`) that provides:

**Invocation tracking:**
- `callCount` - Number of times the member was called
- `invocations` - Array of all invocation arguments
- `lastInvocation` - Most recent invocation arguments

**Return value tracking:**
- `returnedValues` - Array of all returned values
- `lastReturnedValue` - Most recent returned value

**Implementation control:**
- `.returns(value)` - Return a fixed value
- `.invokes { ... }` - Execute custom logic
- `.throws(error)` - Throw an error

## Installation

### Swift Package Manager

Add Swift Mocking to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/fetch-rewards/swift-mocking.git", from: "1.0.0")
]
```

Add to test targets only:

```swift
.testTarget(
    name: "MyTests",
    dependencies: [
        .product(name: "Mocking", package: "swift-mocking")
    ]
)
```

Enable the compilation flag in Package.swift for automatic conditional compilation:

```swift
.define("SWIFT_MOCKING_ENABLED", .when(configuration: .debug))
```

## Compilation Conditions

Control when mocks compile using the `compilationCondition` parameter:

```swift
@Mocked(compilationCondition: .debug)      // #if DEBUG
@Mocked(compilationCondition: .none)       // Always compiled
@Mocked                                     // #if SWIFT_MOCKING_ENABLED (default)
```

**Recommended:** Use `.debug` for one-step usage without additional configuration.

**Default behavior:** Without an explicit condition, mocks use `SWIFT_MOCKING_ENABLED` flag, which requires configuration in Package.swift or Xcode build settings.

## Sendable Conformance

Control Sendable conformance for concurrency safety:

```swift
@Mocked(sendableConformance: .checked)     // Inherits from protocol (default)
@Mocked(sendableConformance: .unchecked)   // @unchecked Sendable
```

Use `.unchecked` when the mock needs to be Sendable but cannot satisfy strict compiler checks (e.g., when mocking protocols with non-Sendable associated types).

## Implementation Constructors

### For Methods

Configure method behavior:

```swift
// Return a fixed value
mock._method.implementation = .returns(42)

// Execute custom logic
mock._method.implementation = .invokes { arg1, arg2 in
    // Custom implementation
    return arg1 + arg2
}

// Throw an error
mock._method.implementation = .throws(MyError.someError)
```

### For Properties

Configure property getters and setters:

```swift
// Read-only property
mock._readOnlyProperty.getter.implementation = .returns(42)

// Read-write property
mock._readWriteProperty.getter.implementation = .returns("value")
mock._readWriteProperty.setter.implementation = .invokes { newValue in
    // Custom setter logic
}
```

### For Non-Sendable Types

When working with non-Sendable types in Swift 6 or with Strict Concurrency enabled:

```swift
// Use unchecked variants to bypass Sendable requirements
mock._nonSendableMethod.implementation = .uncheckedReturns(nonSendableValue)
mock._nonSendableMethod.implementation = .uncheckedInvokes { /* ... */ }
```

Only use unchecked variants when dealing with non-Sendable types. For Sendable types, always use the checked versions.

## Manual Mock Declaration with @MockedMembers

For protocols that inherit from other protocols, `@Mocked` cannot see inherited requirements. Use `@MockedMembers` with manual declaration:

```swift
protocol Dependency: SomeOtherProtocol {
    var ownProperty: Int { get }
    func ownMethod()
}

#if DEBUG
@MockedMembers
final class DependencyMock: Dependency {
    @MockableProperty(.readOnly)
    var ownProperty: Int

    @MockableProperty(.readWrite)
    var inheritedProperty: Int  // From SomeOtherProtocol

    func ownMethod()
    func inheritedMethod()      // From SomeOtherProtocol
}
#endif
```

**Tip:** Use Xcode's Fix-It feature to add protocol requirements, then apply `@MockableProperty` and `@MockableMethod` as needed.

### Property Types

When using `@MockableProperty`, specify the property type:

```swift
@MockableProperty(.readOnly)              // var property: Type { get }
@MockableProperty(.readOnly(.async))      // var property: Type { get async }
@MockableProperty(.readOnly(.throws))     // var property: Type { get throws }
@MockableProperty(.readOnly(.async, .throws))  // var property: Type { get async throws }
@MockableProperty(.readWrite)             // var property: Type { get set }
```

### Custom Method Names

If backing property names conflict, use `@MockableMethod` to specify a custom name:

```swift
@MockedMembers
final class MyMock: MyProtocol {
    @MockableMethod(mockMethodName: "customUniqueName")
    func conflictingMethod()
}
```

## Common Testing Patterns

### Testing Async Methods

```swift
@Mocked(compilationCondition: .debug)
protocol AsyncService {
    func fetchData() async throws -> Data
}

// In tests
let mock = AsyncServiceMock()
mock._fetchData.implementation = .invokes {
    try await Task.sleep(nanoseconds: 100_000)
    return Data()
}

await mock.fetchData()
#expect(mock._fetchData.callCount == 1)
```

### Testing Properties

```swift
@Mocked(compilationCondition: .debug)
protocol DataStore {
    var count: Int { get }
    var items: [String] { get set }
}

// In tests
let mock = DataStoreMock()
mock._count.getter.implementation = .returns(5)
mock._items.getter.implementation = .returns(["a", "b", "c"])

#expect(mock.count == 5)
#expect(mock.items == ["a", "b", "c"])
```

### Verifying Method Arguments

```swift
// After invoking code under test
#expect(mock._method.callCount == 2)
#expect(mock._method.invocations.count == 2)
#expect(mock._method.lastInvocation?.parameter == expectedValue)

// Access all invocations
for invocation in mock._method.invocations {
    // Verify each call
}
```

### Verifying Property Access

```swift
// Check how many times property was accessed
#expect(mock._property.getter.callCount == 3)
#expect(mock._property.setter.callCount == 1)

// Check setter invocations
#expect(mock._property.setter.lastInvocation == newValue)
```

### Testing with Multiple Return Values

```swift
// Return different values on successive calls
var callCount = 0
mock._method.implementation = .invokes {
    callCount += 1
    return callCount * 10
}

#expect(mock.method() == 10)
#expect(mock.method() == 20)
#expect(mock.method() == 30)
```

### Testing Error Handling

```swift
@Mocked(compilationCondition: .debug)
protocol NetworkService {
    func fetchData() async throws -> Data
}

// In tests
let mock = NetworkServiceMock()
mock._fetchData.implementation = .throws(URLError(.notConnectedToInternet))

await #expect(throws: URLError.self) {
    try await mock.fetchData()
}

#expect(mock._fetchData.callCount == 1)
```

### Resetting Static Members

When mocks contain static members, use `resetMockedStaticMembers()` to reset state between tests:

```swift
@MockedMembers
final class ServiceMock: Service {
    static func staticMethod()
}

// In test teardown
override func tearDown() async throws {
    ServiceMock.resetMockedStaticMembers()
    try await super.tearDown()
}
```

## Actor Mocks

Swift Mocking supports protocols that conform to `Actor`:

```swift
@Mocked(compilationCondition: .debug)
protocol DataManager: Actor {
    func save(_ data: Data) async throws
}

// Generates an actor mock
#if DEBUG
@MockedMembers
final actor DataManagerMock: DataManager {
    @MockableMethod
    func save(_ data: Data) async throws
}
#endif

// In tests (note: accessing actor properties requires await)
let mock = DataManagerMock()
await mock._save.implementation = .invokes { _ in }
```

## Associated Types

When protocols define associated types, the generated mock uses them as generic parameters:

```swift
@Mocked(compilationCondition: .debug)
protocol Repository {
    associatedtype Key: Hashable
    associatedtype Value: Equatable

    func fetch(key: Key) -> Value?
}

// Generates:
#if DEBUG
@MockedMembers
final class RepositoryMock<Key: Hashable, Value: Equatable>: Repository {
    @MockableMethod
    func fetch(key: Key) -> Value?
}
#endif

// In tests, specify the types
let mock = RepositoryMock<String, Int>()
mock._fetch.implementation = .returns(42)
```

## Troubleshooting

### Protocol Inheritance

**Problem:** `@Mocked` doesn't generate conformances for inherited protocol requirements.

**Solution:** Use manual mock declaration with `@MockedMembers`:

```swift
protocol Parent {
    func parentMethod()
}

protocol Child: Parent {
    func childMethod()
}

// Use @MockedMembers, not @Mocked
#if DEBUG
@MockedMembers
final class ChildMock: Child {
    func parentMethod()
    func childMethod()
}
#endif
```

### Name Conflicts

**Problem:** Backing property names conflict with method overloads.

**Solution:** Use `@MockableMethod` to specify custom names:

```swift
@MockedMembers
final class MyMock: MyProtocol {
    @MockableMethod(mockMethodName: "fetchUserByID")
    func fetch(userID: String)

    @MockableMethod(mockMethodName: "fetchUserByEmail")
    func fetch(email: String)
}
```

### Non-Sendable Type Errors

**Problem:** Compiler errors about non-Sendable types in `@Sendable` closures.

**Solution:** Use unchecked implementation constructors:

```swift
// Error: Type 'NonSendableType' does not conform to 'Sendable'
mock._method.implementation = .invokes { nonSendableValue }  // ❌

// Solution: Use unchecked variant
mock._method.implementation = .uncheckedInvokes { nonSendableValue }  // ✅
```

### Access Level Mismatches

**Problem:** Generated mock has wrong access level.

**Solution:** The generated mock matches the protocol's access level:
- `public` protocol → `public` mock
- `internal` protocol → `internal` mock
- `fileprivate`/`private` protocol → `fileprivate` mock

Ensure the protocol has the correct access level.

### Compilation Condition Not Working

**Problem:** Mocks always compile or never compile.

**Solution:** Check your compilation condition:

1. For `@Mocked(compilationCondition: .debug)`, ensure you're building in Debug configuration
2. For `@Mocked` (default), add to Package.swift:
   ```swift
   .define("SWIFT_MOCKING_ENABLED", .when(configuration: .debug))
   ```
3. For Xcode projects, add `SWIFT_MOCKING_ENABLED` to build settings under "Swift Compiler - Custom Flags" → "Other Swift Flags" → `-D SWIFT_MOCKING_ENABLED`

## Complete Example

```swift
import Mocking
import Testing

// Protocol definition
@Mocked(compilationCondition: .debug)
protocol UserService {
    func fetchUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws
    var currentUser: User? { get set }
}

// Test implementation
struct UserServiceTests {
    @Test
    func fetchUser_returnsValidUser() async throws {
        // Arrange
        let mock = UserServiceMock()
        let expectedUser = User(id: "123", name: "Alice")
        mock._fetchUser.implementation = .returns(expectedUser)

        // Act
        let user = try await mock.fetchUser(id: "123")

        // Assert
        #expect(user.id == "123")
        #expect(user.name == "Alice")
        #expect(mock._fetchUser.callCount == 1)
        #expect(mock._fetchUser.lastInvocation?.id == "123")
    }

    @Test
    func updateUser_callsService() async throws {
        // Arrange
        let mock = UserServiceMock()
        mock._updateUser.implementation = .invokes { _ in }
        let user = User(id: "123", name: "Bob")

        // Act
        try await mock.updateUser(user)

        // Assert
        #expect(mock._updateUser.callCount == 1)
        #expect(mock._updateUser.lastInvocation?.id == "123")
    }

    @Test
    func currentUser_getterAndSetter() {
        // Arrange
        let mock = UserServiceMock()
        let user = User(id: "123", name: "Charlie")
        mock._currentUser.getter.implementation = .returns(user)
        mock._currentUser.setter.implementation = .invokes { _ in }

        // Act
        let retrievedUser = mock.currentUser
        mock.currentUser = user

        // Assert
        #expect(retrievedUser?.id == "123")
        #expect(mock._currentUser.getter.callCount == 1)
        #expect(mock._currentUser.setter.callCount == 1)
    }
}
```

## Additional Resources

For more detailed information:

- **`macros.md`** - Comprehensive macro documentation for `@Mocked`, `@MockedMembers`, `@MockableProperty`, `@MockableMethod`
- **`features.md`** - Complete list of supported Swift features
- **`usage.md`** - Detailed usage guide with backing property API reference
- **`../examples/example.md`** - Working weather service example
