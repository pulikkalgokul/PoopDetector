# Swift Testing Best Practices

Comprehensive guide to testing best practices, patterns, and debugging strategies.

## Table of Contents

1. [Test Organization](#test-organization)
2. [Writing Effective Tests](#writing-effective-tests)
3. [Test Naming](#test-naming)
4. [Assertion Best Practices](#assertion-best-practices)
5. [Mocking and Stubbing](#mocking-and-stubbing)
6. [Async Testing Patterns](#async-testing-patterns)
7. [Common Pitfalls](#common-pitfalls)
8. [Debugging Techniques](#debugging-techniques)
9. [Performance Considerations](#performance-considerations)
10. [Project-Specific Conventions](#project-specific-conventions)

## Test Organization

### Suite Structure

Organize tests in logical suites:

```swift
@Suite("User Management")
struct UserManagementTests {
    @Suite("User Creation")
    struct CreationTests {
        @Test("Create user with valid data")
        func validUserCreation() { }

        @Test("Reject user with invalid email")
        func invalidEmailRejection() { }
    }

    @Suite("User Authentication")
    struct AuthenticationTests {
        @Test("Authenticate with correct credentials")
        func validAuthentication() { }

        @Test("Reject invalid credentials")
        func invalidCredentialsRejection() { }
    }
}
```

Benefits:
- Clear test organization
- Easy to find related tests
- Logical grouping in test output

### File Organization

**One suite per file**:
```
Tests/
├── UserManagementTests.swift          (UserManagementTests suite)
├── ProductCatalogTests.swift          (ProductCatalogTests suite)
└── PaymentProcessingTests.swift       (PaymentProcessingTests suite)
```

**Multiple related suites**:
```
Tests/
└── UserTests/
    ├── UserCreationTests.swift
    ├── UserAuthenticationTests.swift
    └── UserProfileTests.swift
```

### Shared Test Utilities

Create helpers in separate files:

```swift
// Tests/Helpers/TestData.swift
enum TestData {
    static func makeUser(name: String = "Test User") -> User {
        User(name: name, email: "\(name.lowercased())@example.com")
    }

    static func makeProduct(id: Int = 1) -> Product {
        Product(id: id, name: "Product \(id)", price: 9.99)
    }
}

// Usage in tests
@Test
func userCreation() {
    let user = TestData.makeUser(name: "Alice")
    #expect(user.name == "Alice")
}
```

## Writing Effective Tests

### AAA Pattern

Follow Arrange-Act-Assert:

```swift
@Test
func userRegistration() {
    // Arrange
    let userService = UserService()
    let userData = UserData(name: "Alice", email: "alice@example.com")

    // Act
    let result = userService.register(userData)

    // Assert
    #expect(result.isSuccess)
    #expect(result.user?.name == "Alice")
}
```

### Single Responsibility

Test one thing per test:

❌ **Bad** - Testing multiple things:
```swift
@Test
func userOperations() {
    let user = createUser()
    #expect(user.name == "Alice")

    updateUser(user, name: "Bob")
    #expect(user.name == "Bob")

    deleteUser(user)
    #expect(findUser(user.id) == nil)
}
```

✅ **Good** - Separate tests:
```swift
@Test("Create user with name")
func userCreation() {
    let user = createUser(name: "Alice")
    #expect(user.name == "Alice")
}

@Test("Update user name")
func userUpdate() {
    let user = createUser(name: "Alice")
    updateUser(user, name: "Bob")
    #expect(user.name == "Bob")
}

@Test("Delete user removes from database")
func userDeletion() {
    let user = createUser()
    deleteUser(user)
    #expect(findUser(user.id) == nil)
}
```

### Test Behavior, Not Implementation

Focus on what code does, not how:

❌ **Bad** - Testing implementation details:
```swift
@Test
func userServiceCallsRepository() {
    let mock = MockUserRepository()
    let service = UserService(repository: mock)

    service.getUser(id: 1)

    #expect(mock.findUserCalled)
    #expect(mock.findUserCallCount == 1)
}
```

✅ **Good** - Testing behavior:
```swift
@Test
func userServiceReturnsUser() {
    let mock = MockUserRepository()
    mock.findUserReturnValue = User(id: 1, name: "Alice")
    let service = UserService(repository: mock)

    let user = service.getUser(id: 1)

    #expect(user?.name == "Alice")
}
```

### Avoid Test Interdependence

Tests should run independently:

❌ **Bad** - Tests depend on each other:
```swift
@Suite
struct BadTests {
    static var sharedUser: User?

    @Test
    func test1_createUser() {
        Self.sharedUser = createUser()
        #expect(Self.sharedUser != nil)
    }

    @Test
    func test2_updateUser() {
        // Depends on test1 running first!
        updateUser(Self.sharedUser!, name: "Bob")
        #expect(Self.sharedUser?.name == "Bob")
    }
}
```

✅ **Good** - Independent tests:
```swift
@Suite
struct GoodTests {
    @Test
    func createUser() {
        let user = createUser()
        #expect(user != nil)
    }

    @Test
    func updateUser() {
        let user = createUser()  // Create fresh user
        updateUser(user, name: "Bob")
        #expect(user.name == "Bob")
    }
}
```

## Test Naming

### Descriptive Labels

Use clear, descriptive test labels:

❌ **Bad** - Vague names:
```swift
@Test
func test1() { }

@Test
func userTest() { }

@Test
func it_works() { }
```

✅ **Good** - Descriptive names:
```swift
@Test("Create user with valid email")
func createUserWithValidEmail() { }

@Test("Reject user registration with duplicate email")
func rejectDuplicateEmailRegistration() { }

@Test("Update user profile updates modified date")
func updateProfileUpdatesModifiedDate() { }
```

### Naming Convention

Follow "what_condition_expectedResult" or use descriptive sentences:

**Pattern 1: Action_Condition_Result**
```swift
@Test("Register user with valid data creates account")
func registerUser_validData_createsAccount() { }

@Test("Login with invalid password returns error")
func login_invalidPassword_returnsError() { }
```

**Pattern 2: Descriptive sentence**
```swift
@Test("User registration creates account and sends welcome email")
func userRegistrationFlow() { }

@Test("Payment processing charges card and creates transaction")
func paymentProcessing() { }
```

Choose one pattern and stick with it in your project.

## Assertion Best Practices

### Use Appropriate Assertions

Choose the right assertion for the check:

```swift
// Boolean checks
#expect(user.isActive)
#expect(!user.isDeleted)

// Equality
#expect(user.name == "Alice")
#expect(user.age == 25)

// Nil checks
#expect(user.deletedAt == nil)
#expect(user.createdAt != nil)

// Comparisons
#expect(user.score > 0)
#expect(user.age >= 18)

// Collections
#expect(users.isEmpty)
#expect(users.count == 3)
#expect(users.contains(alice))
```

### Add Context with Custom Messages

Provide helpful failure messages:

❌ **Bad** - No context:
```swift
@Test
func validation() {
    #expect(result.isValid)
}
// Failure: "Expectation failed: result.isValid"
```

✅ **Good** - Clear context:
```swift
@Test
func validation() {
    #expect(result.isValid, "Validation failed for input: \(input)")
}
// Failure: "Validation failed for input: invalid@email"
```

### Multiple Related Assertions

Group related checks:

```swift
@Test
func userCreation() {
    let user = createUser(name: "Alice", age: 25, email: "alice@example.com")

    // All properties are set correctly
    #expect(user.name == "Alice", "Name should be Alice")
    #expect(user.age == 25, "Age should be 25")
    #expect(user.email == "alice@example.com", "Email should match")
    #expect(!user.isDeleted, "User should not be deleted on creation")
    #expect(user.createdAt != nil, "Created date should be set")
}
```

### Avoid Over-Assertion

Don't check irrelevant details:

❌ **Bad** - Too many checks:
```swift
@Test
func userCreation() {
    let user = createUser(name: "Alice")

    #expect(user.name == "Alice")
    #expect(user.id != 0)
    #expect(user.createdAt != nil)
    #expect(user.updatedAt != nil)
    #expect(user.version == 1)
    #expect(user.isActive == true)
    #expect(user.isDeleted == false)
    // ... and 10 more assertions
}
```

✅ **Good** - Focus on what matters:
```swift
@Test
func userCreationSetsName() {
    let user = createUser(name: "Alice")
    #expect(user.name == "Alice")
}

@Test
func userCreationSetsDefaultActiveState() {
    let user = createUser(name: "Alice")
    #expect(user.isActive)
    #expect(!user.isDeleted)
}
```

## Mocking and Stubbing

### Use Protocol-Based Mocking

Define protocols for dependencies:

```swift
protocol UserRepository {
    func findUser(id: Int) async -> User?
    func saveUser(_ user: User) async throws
}

// Mock implementation
final class MockUserRepository: UserRepository {
    var findUserReturnValue: User?
    var saveUserError: Error?

    func findUser(id: Int) async -> User? {
        findUserReturnValue
    }

    func saveUser(_ user: User) async throws {
        if let error = saveUserError {
            throw error
        }
    }
}
```

### Project-Specific: @Mocked Macro

Use the `@Mocked` macro for automatic mock generation:

```swift
@Mocked
protocol UserRepository {
    func findUser(id: Int) async -> User?
    func saveUser(_ user: User) async throws
}

@Test
func fetchUser() async {
    let mock = UserRepositoryMock()
    mock.findUserReturnValue = User(id: 1, name: "Alice")

    let service = UserService(repository: mock)
    let user = await service.fetchUser(id: 1)

    #expect(user?.name == "Alice")
}
```

### Stub Only What's Needed

Don't over-configure mocks:

❌ **Bad** - Configuring unused mocks:
```swift
@Test
func fetchUser() async {
    let mock = UserRepositoryMock()
    mock.findUserReturnValue = User(id: 1, name: "Alice")
    mock.saveUserError = NetworkError.timeout  // Not used in this test!
    mock.deleteUserReturnValue = true          // Not used in this test!

    let user = await service.fetchUser(id: 1)
    #expect(user?.name == "Alice")
}
```

✅ **Good** - Configure only what's needed:
```swift
@Test
func fetchUser() async {
    let mock = UserRepositoryMock()
    mock.findUserReturnValue = User(id: 1, name: "Alice")

    let user = await service.fetchUser(id: 1)
    #expect(user?.name == "Alice")
}
```

## Async Testing Patterns

### Simple Async Operations

```swift
@Test
func fetchData() async {
    let result = await repository.fetchData()
    #expect(result.count > 0)
}
```

### Async with Error Handling

```swift
@Test
func fetchDataHandlesErrors() async {
    do {
        let result = try await repository.fetchData()
        #expect(result.count > 0)
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

// Or with throws
@Test
func fetchData() async throws {
    let result = try await repository.fetchData()
    #expect(result.count > 0)
}
```

### Concurrent Operations

```swift
@Test
func multipleFetches() async {
    async let users = repository.fetchUsers()
    async let products = repository.fetchProducts()

    let (userResults, productResults) = await (users, products)

    #expect(userResults.count > 0)
    #expect(productResults.count > 0)
}
```

### Testing Timeouts

```swift
@Test(.timeLimit(.seconds(5)))
func slowOperation() async {
    await performSlowOperation()
    // Test fails if takes longer than 5 seconds
}
```

## Common Pitfalls

### Pitfall 1: Not Using async for Async Tests

❌ **Bad**:
```swift
@Test
func fetchData() {
    Task {
        let result = await repository.fetchData()
        #expect(result.count > 0)
    }
    // Test finishes before Task completes!
}
```

✅ **Good**:
```swift
@Test
func fetchData() async {
    let result = await repository.fetchData()
    #expect(result.count > 0)
}
```

### Pitfall 2: Force Unwrapping

❌ **Bad**:
```swift
@Test
func userFetch() {
    let user = findUser(id: 1)!  // Crashes if nil
    #expect(user.name == "Alice")
}
```

✅ **Good**:
```swift
@Test
func userFetch() throws {
    let user = try #require(findUser(id: 1))
    #expect(user.name == "Alice")
}
```

### Pitfall 3: Testing Too Much in One Test

❌ **Bad**:
```swift
@Test
func userFlow() {
    // Create
    let user = createUser()
    #expect(user.id != 0)

    // Update
    updateUser(user, name: "Bob")
    #expect(user.name == "Bob")

    // Authenticate
    let authenticated = authenticate(user)
    #expect(authenticated)

    // Delete
    deleteUser(user)
    #expect(findUser(user.id) == nil)
}
```

✅ **Good** - Split into focused tests:
```swift
@Test func userCreation() { }
@Test func userUpdate() { }
@Test func userAuthentication() { }
@Test func userDeletion() { }
```

### Pitfall 4: Mutable Shared State

❌ **Bad**:
```swift
@Suite
struct Tests {
    static var counter = 0  // Shared mutable state!

    @Test
    func test1() {
        Self.counter += 1
        #expect(Self.counter == 1)  // Fails if test2 runs first
    }

    @Test
    func test2() {
        Self.counter += 1
        #expect(Self.counter == 1)  // Fails if test1 runs first
    }
}
```

✅ **Good**:
```swift
@Suite
struct Tests {
    @Test
    func test1() {
        var counter = 0
        counter += 1
        #expect(counter == 1)
    }

    @Test
    func test2() {
        var counter = 0
        counter += 1
        #expect(counter == 1)
    }
}
```

## Debugging Techniques

### Add Descriptive Labels

Help identify failing tests:

```swift
@Test("User registration with valid email creates active account")
func userRegistration() {
    // Test code
}
// Clear what test does from label
```

### Use Custom Assertion Messages

Provide context on failures:

```swift
@Test
func validation() {
    let result = validate(input)
    #expect(
        result.isValid,
        "Validation failed for input '\(input)': \(result.errors.joined(separator: ", "))"
    )
}
```

### Break Down Complex Tests

Split complex tests for easier debugging:

❌ **Bad**:
```swift
@Test
func complexFlow() {
    let a = step1()
    let b = step2(a)
    let c = step3(b)
    let d = step4(c)
    #expect(d.isValid)  // Which step failed?
}
```

✅ **Good**:
```swift
@Test
func step1ProducesValidOutput() {
    let a = step1()
    #expect(a.isValid)
}

@Test
func step2TransformsCorrectly() {
    let a = validInputForStep2()
    let b = step2(a)
    #expect(b.isValid)
}
// ... etc
```

### Use Print Debugging

Add temporary logging:

```swift
@Test
func debugging() {
    let input = prepareInput()
    print("Input: \(input)")

    let result = process(input)
    print("Result: \(result)")

    #expect(result.isValid)
}
```

### Isolate Failures

Use `.disabled()` to focus on specific tests:

```swift
@Test(.disabled("Debug test1 first"))
func test2() { }

@Test(.disabled("Debug test1 first"))
func test3() { }

@Test
func test1() {
    // Focus on this test
}
```

## Performance Considerations

### Use Test Timeouts

Catch slow tests:

```swift
@Test(.timeLimit(.seconds(1)))
func shouldBeFast() {
    // Test fails if takes > 1 second
    performOperation()
}
```

### Parallelize Independent Tests

Tests run in parallel by default. Force serial execution only when needed:

```swift
@Suite(.serialized)  // Only if tests must run in order
struct SerialTests {
    @Test func first() { }
    @Test func second() { }
}
```

### Use In-Memory Databases for Tests

Fast test execution:

```swift
@Suite
struct DatabaseTests {
    let database: Database

    init() {
        database = Database(inMemory: true)  // Fast!
    }
}
```

### Avoid Unnecessary Setup

Lazy initialization:

```swift
@Suite
struct Tests {
    // Only created if tests need it
    static let expensiveResource: ExpensiveResource = {
        ExpensiveResource()
    }()
}
```

## Project-Specific Conventions

### Test File Naming

Name test files with `Tests` suffix:
- `UserManager.swift` → `UserManagerTests.swift`
- `PaymentService.swift` → `PaymentServiceTests.swift`

### Test Location

Place tests in `Tests/` directory within the same module:
```
FetchPackage/
├── Sources/
│   └── FetchPackage/
│       └── UserManager.swift
└── Tests/
    └── FetchPackageTests/
        └── UserManagerTests.swift
```

### Timeout Convention

Use 5.0 seconds for fulfillment (when needed):
```swift
await fulfillment(of: [expectation], timeout: 5.0)
```

### Dependency Injection

Always inject dependencies via protocols:

```swift
@Test
func serviceTest() {
    let mockRepo: any UserRepository = MockUserRepository()
    let service = UserService(repository: mockRepo)
    // Test with mock
}
```

### Using @Mocked Macro

Prefer `@Mocked` for generating mocks:

```swift
@Mocked
protocol MyService {
    func fetch() async -> Data
}

// Generates MyServiceMock automatically
```

## Summary

Key best practices:

1. **Organization**: Use `@Suite` to group related tests
2. **Naming**: Descriptive test names and labels
3. **AAA Pattern**: Arrange, Act, Assert
4. **Single Responsibility**: One test, one thing
5. **Independence**: Tests don't depend on each other
6. **Behavior Testing**: Test what code does, not how
7. **Async**: Use `async` functions, not expectations
8. **Mocking**: Protocol-based with `@Mocked` macro
9. **Assertions**: Clear, focused, with custom messages
10. **Debugging**: Labels, messages, isolation

Follow these practices for maintainable, reliable tests that clearly document expected behavior.
