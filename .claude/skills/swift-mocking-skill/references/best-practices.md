# Swift Mocking Best Practices

Best practices, advanced patterns, and common pitfalls when using Swift Mocking.

## Best Practices

### 1. Always Specify Compilation Condition

**✅ Recommended:**
```swift
@Mocked(compilationCondition: .debug)
protocol MyService {}
```

**Why:** Ensures mocks only compile in test builds without additional configuration. The default `SWIFT_MOCKING_ENABLED` requires Package.swift setup.

### 2. Use Checked Implementation Constructors

**✅ For Sendable types:**
```swift
mock._method.implementation = .returns(42)
mock._method.implementation = .invokes { arg in
    return processArg(arg)
}
```

**❌ Avoid unchecked unless necessary:**
```swift
// Only use when type is non-Sendable
mock._method.implementation = .uncheckedReturns(value)
```

**Why:** Checked constructors enforce concurrency safety. Use unchecked only when the compiler cannot verify Sendability but you know the usage is safe.

### 3. Verify Both Call Counts and Arguments

**✅ Comprehensive verification:**
```swift
#expect(mock._method.callCount == 1)
#expect(mock._method.lastInvocation?.parameter == expectedValue)
```

**❌ Insufficient verification:**
```swift
#expect(mock._method.callCount == 1)  // Only checks call count
```

**Why:** Verifying arguments ensures the mock was called with correct values, not just that it was called.

### 4. Reset Static Members Between Tests

**✅ Clean state:**
```swift
@Suite
struct MyTests {
    init() {
        MyMock.resetMockedStaticMembers()
    }

    @Test
    func test1() { /* ... */ }

    @Test
    func test2() { /* ... */ }
}
```

**Why:** Static state persists across tests. Reset to avoid test interdependencies.

### 5. Use Fix-It for Manual Mocks

When using `@MockedMembers` for inherited protocols:

1. Write the mock class declaration
2. Let Xcode show "Type does not conform to protocol" error
3. Click Fix-It to add requirements
4. Apply `@MockableProperty` where needed
5. Leave methods without attributes (they work automatically)

**✅ Efficient workflow:**
```swift
// Step 1: Declare mock
#if DEBUG
@MockedMembers
final class MyMock: ParentProtocol {
    // Step 3: Fix-It adds requirements
    // Step 4: Add @MockableProperty
    @MockableProperty(.readOnly)
    var property: Int

    // Step 5: Methods work without attributes
    func method()
}
#endif
```

### 6. Keep Mocks Simple

**✅ Simple mock behavior:**
```swift
mock._method.implementation = .returns(42)
```

**❌ Overly complex mock:**
```swift
mock._method.implementation = .invokes { arg in
    // 50 lines of complex logic
    // Multiple branches
    // Database calls
    // Network requests
}
```

**Why:** Complex mocks are hard to maintain and may hide bugs. If mock logic is complex, consider testing the real implementation instead.

### 7. Use Project Dependency Injection Pattern

Follow the project's composer pattern when mocking dependencies:

```swift
// In package
public enum ServiceComposer {
    public static func make(
        dependency: any DependencyProtocol
    ) -> some ServiceProtocol {
        DefaultService(dependency: dependency)
    }
}

// In tests
@Test
func testService() {
    let mockDependency = DependencyProtocolMock()
    mockDependency._method.implementation = .returns(42)

    let service = ServiceComposer.make(dependency: mockDependency)

    // Test service with mocked dependency
}
```

## Advanced Patterns

### Pattern 1: Sequence of Return Values

Return different values on successive calls:

```swift
var responses = [10, 20, 30]
mock._method.implementation = .invokes {
    responses.removeFirst()
}

#expect(mock.method() == 10)
#expect(mock.method() == 20)
#expect(mock.method() == 30)
```

### Pattern 2: Conditional Behavior

Implement different behavior based on arguments:

```swift
mock._fetchUser.implementation = .invokes { userID in
    switch userID {
    case "admin":
        return User(id: "admin", role: .admin)
    case "user":
        return User(id: "user", role: .standard)
    default:
        throw UserError.notFound
    }
}
```

### Pattern 3: Stateful Mocks

Track state across invocations:

```swift
var storedValue: String?

mock._saveValue.implementation = .invokes { value in
    storedValue = value
}

mock._getValue.implementation = .invokes {
    guard let value = storedValue else {
        throw Error.noValue
    }
    return value
}

// Tests can verify state changes
try mock.saveValue("test")
#expect(try mock.getValue() == "test")
```

### Pattern 4: Async Delays

Simulate network latency:

```swift
mock._fetchData.implementation = .invokes {
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    return Data()
}
```

### Pattern 5: Call Order Verification

Verify methods called in specific order:

```swift
var callOrder: [String] = []

mock._methodA.implementation = .invokes { callOrder.append("A") }
mock._methodB.implementation = .invokes { callOrder.append("B") }
mock._methodC.implementation = .invokes { callOrder.append("C") }

// Execute code under test
await systemUnderTest.execute()

// Verify order
#expect(callOrder == ["A", "B", "C"])
```

### Pattern 6: Property Observation

Track all property changes:

```swift
var propertyHistory: [Int] = []

mock._count.setter.implementation = .invokes { newValue in
    propertyHistory.append(newValue)
}

mock.count = 1
mock.count = 5
mock.count = 10

#expect(propertyHistory == [1, 5, 10])
```

### Pattern 7: Partial Mocking

Mix real and mocked behavior:

```swift
@Mocked(compilationCondition: .debug)
protocol Calculator {
    func add(_ a: Int, _ b: Int) -> Int
    func multiply(_ a: Int, _ b: Int) -> Int
}

let mock = CalculatorMock()

// Real implementation for add
mock._add.implementation = .invokes { a, b in a + b }

// Mocked implementation for multiply
mock._multiply.implementation = .returns(100)

#expect(mock.add(2, 3) == 5)      // Real behavior
#expect(mock.multiply(2, 3) == 100)  // Mocked behavior
```

## Common Pitfalls

### Pitfall 1: Forgetting to Set Implementation

**❌ Problem:**
```swift
let mock = ServiceMock()
// Forgot to set implementation
let result = mock.fetchData()  // Returns default value or crashes
```

**✅ Solution:**
```swift
let mock = ServiceMock()
mock._fetchData.implementation = .returns(Data())  // Always set implementation
let result = mock.fetchData()
```

### Pitfall 2: Using Wrong Compilation Condition

**❌ Problem:**
```swift
@Mocked  // Uses SWIFT_MOCKING_ENABLED (not configured)
protocol Service {}

// Mock never compiles
```

**✅ Solution:**
```swift
@Mocked(compilationCondition: .debug)  // Explicitly use .debug
protocol Service {}
```

### Pitfall 3: Not Resetting Mocks Between Tests

**❌ Problem:**
```swift
struct Tests {
    let sharedMock = ServiceMock()

    @Test
    func test1() {
        sharedMock._method.implementation = .returns(10)
        // test1 passes
    }

    @Test
    func test2() {
        // test2 uses test1's implementation!
        #expect(sharedMock.method() == 20)  // Fails!
    }
}
```

**✅ Solution:**
```swift
struct Tests {
    @Test
    func test1() {
        let mock = ServiceMock()  // New instance per test
        mock._method.implementation = .returns(10)
    }

    @Test
    func test2() {
        let mock = ServiceMock()  // Fresh instance
        mock._method.implementation = .returns(20)
    }
}
```

### Pitfall 4: Testing the Mock Instead of Code Under Test

**❌ Problem:**
```swift
@Test
func testMock() {
    let mock = ServiceMock()
    mock._method.implementation = .returns(42)

    #expect(mock.method() == 42)  // Just testing the mock!
}
```

**✅ Solution:**
```swift
@Test
func testViewModel() {
    let mock = ServiceMock()
    mock._method.implementation = .returns(42)

    let viewModel = ViewModel(service: mock)  // Inject mock
    await viewModel.load()  // Test real code

    #expect(viewModel.value == 42)  // Test code under test
    #expect(mock._method.callCount == 1)  // Verify mock was used
}
```

### Pitfall 5: Over-Mocking

**❌ Problem:**
```swift
// Mocking everything, including simple types
@Mocked(compilationCondition: .debug)
protocol IntWrapper {
    var value: Int { get }
}

let mock = IntWrapperMock()
mock._value.getter.implementation = .returns(42)
```

**✅ Solution:**
```swift
// Just use the real type
struct IntWrapper {
    let value: Int
}

let wrapper = IntWrapper(value: 42)
```

**Why:** Only mock external dependencies (network, database, etc.). Don't mock value types or simple structs.

### Pitfall 6: Ignoring Invocation Verification

**❌ Problem:**
```swift
@Test
func testDelete() {
    let mock = ServiceMock()
    mock._delete.implementation = .invokes { _ in }

    await viewModel.deleteItem(id: "123")

    // No verification!
}
```

**✅ Solution:**
```swift
@Test
func testDelete() {
    let mock = ServiceMock()
    mock._delete.implementation = .invokes { _ in }

    await viewModel.deleteItem(id: "123")

    #expect(mock._delete.callCount == 1)
    #expect(mock._delete.lastInvocation == "123")
}
```

### Pitfall 7: Mocking Protocols with Inheritance

**❌ Problem:**
```swift
@Mocked(compilationCondition: .debug)
protocol Child: Parent {
    func childMethod()
}
// Mock doesn't include Parent's requirements!
```

**✅ Solution:**
```swift
#if DEBUG
@MockedMembers
final class ChildMock: Child {
    func parentMethod()  // Add manually
    func childMethod()
}
#endif
```

## Testing Strategies

### Strategy 1: Test Behavior, Not Implementation

**✅ Good:**
```swift
@Test
func userService_fetchesUserData() async throws {
    let mock = APIClientMock()
    mock._get.implementation = .returns(userData)

    let service = UserService(apiClient: mock)
    let user = try await service.fetchUser(id: "123")

    #expect(user.name == "Alice")  // Test behavior
}
```

**❌ Bad:**
```swift
@Test
func userService_callsAPIClient() async throws {
    let mock = APIClientMock()
    mock._get.implementation = .returns(userData)

    let service = UserService(apiClient: mock)
    _ = try await service.fetchUser(id: "123")

    #expect(mock._get.callCount == 1)  // Only tests implementation detail
}
```

### Strategy 2: Use Descriptive Test Names

**✅ Good:**
```swift
@Test
func fetchUser_whenAPIReturnsError_throwsError() async throws { }

@Test
func fetchUser_whenAPIReturnsData_returnsUser() async throws { }
```

**❌ Bad:**
```swift
@Test
func test1() async throws { }

@Test
func test2() async throws { }
```

### Strategy 3: Arrange-Act-Assert Pattern

Always structure tests with clear sections:

```swift
@Test
func descriptiveTestName() async throws {
    // Arrange - Set up mocks and dependencies
    let mock = ServiceMock()
    mock._method.implementation = .returns(42)
    let sut = SystemUnderTest(service: mock)

    // Act - Execute the code under test
    let result = await sut.performAction()

    // Assert - Verify results and mock invocations
    #expect(result == expectedValue)
    #expect(mock._method.callCount == 1)
}
```

## Performance Considerations

### Consider: Mock Generation Time

Swift macros run at compile time. Complex protocols generate more code:

- **Simple protocol (1-2 members):** Negligible impact
- **Large protocol (20+ members):** Noticeable but acceptable
- **Hundreds of protocols:** May impact build times

**Mitigation:** Only mock what you test. Don't apply `@Mocked` to every protocol.

### Consider: Test Execution Time

Mock invocations have minimal overhead:

- Accessing backing properties: ~1-2 nanoseconds
- Setting implementations: ~10-20 nanoseconds
- Recording invocations: ~50-100 nanoseconds

**Conclusion:** Performance impact is negligible for typical test suites.

## Debugging Tips

### Tip 1: Expand Macros to See Generated Code

In Xcode:
1. Right-click on `@Mocked` or `@MockedMembers`
2. Select "Expand Macro"
3. See exactly what code was generated

Helps understand backing property structure and troubleshoot issues.

### Tip 2: Print Invocation History

```swift
// Print all invocations
print(mock._method.invocations)

// Print call count
print("Called \(mock._method.callCount) times")

// Print return values
print(mock._method.returnedValues)
```

### Tip 3: Use Breakpoints in Mock Implementations

```swift
mock._method.implementation = .invokes { arg in
    print("Mock called with: \(arg)")  // Add breakpoint here
    return 42
}
```

### Tip 4: Check Compilation Conditions

If mocks aren't available:

```swift
#if DEBUG
print("Mocks are compiled in this build")
#else
print("Mocks are NOT compiled in this build")
#endif
```

## Migration from Other Mocking Libraries

### From Manual Mocks

**Before:**
```swift
class ServiceMock: Service {
    var fetchDataCallCount = 0
    var fetchDataReturnValue: Data?

    func fetchData() async throws -> Data {
        fetchDataCallCount += 1
        guard let returnValue = fetchDataReturnValue else {
            fatalError("Return value not set")
        }
        return returnValue
    }
}
```

**After:**
```swift
@Mocked(compilationCondition: .debug)
protocol Service {
    func fetchData() async throws -> Data
}

// Generated automatically!
// Use: ServiceMock()
```

### From Closure-Based Mocks

**Before:**
```swift
class ServiceMock: Service {
    var fetchDataClosure: (() async throws -> Data)?

    func fetchData() async throws -> Data {
        guard let closure = fetchDataClosure else {
            fatalError("Closure not set")
        }
        return try await closure()
    }
}
```

**After:**
```swift
@Mocked(compilationCondition: .debug)
protocol Service {
    func fetchData() async throws -> Data
}

// In tests
mock._fetchData.implementation = .invokes {
    return Data()
}
```

## Summary

**Key Takeaways:**

1. Always use `compilationCondition: .debug` for simplicity
2. Prefer checked implementation constructors for Sendable types
3. Verify both call counts and arguments
4. Reset static members between tests
5. Keep mock behavior simple
6. Use Fix-It for manual mocks with `@MockedMembers`
7. Test behavior, not implementation details
8. Create fresh mock instances per test
9. Only mock external dependencies
10. Follow the Arrange-Act-Assert pattern

**When in Doubt:**

- Expand macros to see generated code
- Print invocation history for debugging
- Consult `swift-mocking-basics.md` for detailed usage
- Check `macros.md` for macro documentation
