# XCTest to Swift Testing Migration Guide

Comprehensive patterns and examples for migrating from XCTest to Swift Testing.

## Table of Contents

1. [Migration Overview](#migration-overview)
2. [Test Class Structure](#test-class-structure)
3. [Assertion Migration](#assertion-migration)
4. [Async Testing Migration](#async-testing-migration)
5. [Setup and Teardown](#setup-and-teardown)
6. [Mocking and Stubbing](#mocking-and-stubbing)
7. [Common Patterns](#common-patterns)
8. [Edge Cases](#edge-cases)

## Migration Overview

### Why Migrate?

- **Cleaner syntax**: Less boilerplate, more expressive
- **Better async support**: No more expectations and waiting
- **Type safety**: Compile-time checking of assertions
- **Parameterized tests**: Built-in support for testing multiple inputs
- **Improved errors**: Clearer failure messages

### Migration Strategy

1. **Start with leaf tests**: Tests with fewest dependencies
2. **Migrate test-by-test**: Don't migrate entire file at once
3. **Run tests frequently**: Ensure each migration works
4. **Update mocks**: Convert mock protocols if needed
5. **Leverage async**: Simplify async tests immediately

## Test Class Structure

### XCTest Class

```swift
import XCTest
@testable import MyModule

final class UserTests: XCTestCase {
    var sut: UserManager!

    override func setUp() {
        super.setUp()
        sut = UserManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testUserCreation() {
        let user = sut.createUser(name: "Alice")
        XCTAssertEqual(user.name, "Alice")
    }

    func testUserDeletion() {
        let user = sut.createUser(name: "Bob")
        sut.deleteUser(user)
        XCTAssertTrue(sut.users.isEmpty)
    }
}
```

### Swift Testing Equivalent

```swift
import Testing
@testable import MyModule

@Suite("User Management")
struct UserTests {
    let sut: UserManager

    init() {
        sut = UserManager()
    }

    @Test("User creation with name")
    func userCreation() {
        let user = sut.createUser(name: "Alice")
        #expect(user.name == "Alice")
    }

    @Test("User deletion removes from list")
    func userDeletion() {
        let user = sut.createUser(name: "Bob")
        sut.deleteUser(user)
        #expect(sut.users.isEmpty)
    }
}
```

### Key Changes

1. **Class → Struct**: `final class` becomes `@Suite struct`
2. **Inheritance removed**: No `: XCTestCase`
3. **setUp() → init()**: Setup logic moves to initializer
4. **tearDown() → deinit**: Cleanup logic moves to deinitializer
5. **testXxx() → @Test**: Test prefix removed, add `@Test` attribute
6. **var → let**: Properties can be immutable if not mutated

## Assertion Migration

### Complete Assertion Mapping

| XCTest | Swift Testing | Notes |
|--------|---------------|-------|
| `XCTAssertTrue(x)` | `#expect(x)` | Direct boolean check |
| `XCTAssertFalse(x)` | `#expect(!x)` | Negate condition |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` | Equality |
| `XCTAssertNotEqual(a, b)` | `#expect(a != b)` | Inequality |
| `XCTAssertNil(x)` | `#expect(x == nil)` | Nil check |
| `XCTAssertNotNil(x)` | `#expect(x != nil)` | Non-nil check |
| `XCTAssertGreaterThan(a, b)` | `#expect(a > b)` | Greater than |
| `XCTAssertLessThan(a, b)` | `#expect(a < b)` | Less than |
| `XCTAssertGreaterThanOrEqual(a, b)` | `#expect(a >= b)` | Greater or equal |
| `XCTAssertLessThanOrEqual(a, b)` | `#expect(a <= b)` | Less or equal |
| `XCTAssertThrowsError { }` | `#expect(throws: Error.self) { }` | Error throwing |
| `XCTUnwrap(x)` | `try #require(x)` | Optional unwrapping |
| `XCTFail("message")` | `Issue.record("message")` | Explicit failure |

### Examples

#### Boolean Assertions

```swift
// XCTest
XCTAssertTrue(user.isActive)
XCTAssertFalse(user.isDeleted)

// Swift Testing
#expect(user.isActive)
#expect(!user.isDeleted)
```

#### Equality Assertions

```swift
// XCTest
XCTAssertEqual(user.name, "Alice")
XCTAssertNotEqual(user.id, 0)

// Swift Testing
#expect(user.name == "Alice")
#expect(user.id != 0)
```

#### Nil Assertions

```swift
// XCTest
XCTAssertNil(user.deletedAt)
XCTAssertNotNil(user.createdAt)

// Swift Testing
#expect(user.deletedAt == nil)
#expect(user.createdAt != nil)
```

#### Comparison Assertions

```swift
// XCTest
XCTAssertGreaterThan(user.age, 18)
XCTAssertLessThanOrEqual(user.score, 100)

// Swift Testing
#expect(user.age > 18)
#expect(user.score <= 100)
```

#### Collection Assertions

```swift
// XCTest
XCTAssertTrue(users.isEmpty)
XCTAssertEqual(users.count, 3)
XCTAssertTrue(users.contains(alice))

// Swift Testing
#expect(users.isEmpty)
#expect(users.count == 3)
#expect(users.contains(alice))
```

#### Error Assertions

```swift
// XCTest
XCTAssertThrowsError(try validate(input)) { error in
    XCTAssertEqual(error as? ValidationError, .invalid)
}

// Swift Testing
#expect(throws: ValidationError.invalid) {
    try validate(input)
}
```

#### Optional Unwrapping

```swift
// XCTest
func testUser() throws {
    let user = try XCTUnwrap(findUser(id: 1))
    XCTAssertEqual(user.name, "Alice")
}

// Swift Testing
@Test
func user() throws {
    let user = try #require(findUser(id: 1))
    #expect(user.name == "Alice")
}
```

## Async Testing Migration

### XCTest Async (Expectations)

```swift
func testAsyncOperation() {
    let expectation = XCTestExpectation(description: "Fetch completes")

    fetchData { result in
        XCTAssertEqual(result.count, 5)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}
```

### Swift Testing Async

```swift
@Test
func asyncOperation() async {
    let result = await fetchData()
    #expect(result.count == 5)
}
```

### Multiple Expectations

```swift
// XCTest
func testMultipleAsync() {
    let exp1 = XCTestExpectation()
    let exp2 = XCTestExpectation()

    fetchData { data in
        XCTAssertNotNil(data)
        exp1.fulfill()
    }

    saveData { success in
        XCTAssertTrue(success)
        exp2.fulfill()
    }

    wait(for: [exp1, exp2], timeout: 5.0)
}

// Swift Testing
@Test
func multipleAsync() async {
    async let data = fetchData()
    async let success = saveData()

    let (dataResult, successResult) = await (data, success)

    #expect(dataResult != nil)
    #expect(successResult)
}
```

### Async Sequences

```swift
// XCTest
func testAsyncSequence() {
    let expectation = XCTestExpectation()
    var values: [Int] = []

    Task {
        for await value in stream() {
            values.append(value)
        }
        XCTAssertEqual(values, [1, 2, 3])
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}

// Swift Testing
@Test
func asyncSequence() async {
    var values: [Int] = []
    for await value in stream() {
        values.append(value)
    }
    #expect(values == [1, 2, 3])
}
```

### Async Throws

```swift
// XCTest
func testAsyncThrows() {
    let expectation = XCTestExpectation()

    Task {
        do {
            let result = try await fetchData()
            XCTAssertGreaterThan(result.count, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}

// Swift Testing
@Test
func asyncThrows() async throws {
    let result = try await fetchData()
    #expect(result.count > 0)
}
```

## Setup and Teardown

### Per-Test Setup

```swift
// XCTest
final class DatabaseTests: XCTestCase {
    var database: Database!

    override func setUp() {
        super.setUp()
        database = Database(inMemory: true)
        database.migrate()
    }

    override func tearDown() {
        database.close()
        database = nil
        super.tearDown()
    }

    func testInsert() {
        database.insert(user)
        XCTAssertEqual(database.count, 1)
    }
}

// Swift Testing
@Suite
struct DatabaseTests {
    let database: Database

    init() {
        database = Database(inMemory: true)
        database.migrate()
    }

    deinit {
        database.close()
    }

    @Test
    func insert() {
        database.insert(user)
        #expect(database.count == 1)
    }
}
```

### Class-Level Setup

```swift
// XCTest
final class APITests: XCTestCase {
    static var apiClient: APIClient!

    override class func setUp() {
        super.setUp()
        apiClient = APIClient()
        apiClient.authenticate()
    }

    override class func tearDown() {
        apiClient.logout()
        apiClient = nil
        super.tearDown()
    }

    func testFetch() {
        let data = Self.apiClient.fetch()
        XCTAssertNotNil(data)
    }
}

// Swift Testing
@Suite
struct APITests {
    static let apiClient: APIClient = {
        let client = APIClient()
        client.authenticate()
        return client
    }()

    @Test
    func fetch() {
        let data = Self.apiClient.fetch()
        #expect(data != nil)
    }
}
```

**Note**: Swift Testing doesn't have class-level teardown. Use `defer` or manual cleanup if needed.

## Mocking and Stubbing

### XCTest Mock

```swift
// Mock protocol
protocol UserService {
    func fetchUser(id: Int) -> User?
}

// XCTest mock
final class MockUserService: UserService {
    var fetchUserCalled = false
    var fetchUserReturnValue: User?

    func fetchUser(id: Int) -> User? {
        fetchUserCalled = true
        return fetchUserReturnValue
    }
}

// XCTest test
final class ViewModelTests: XCTestCase {
    func testFetchUser() {
        let mock = MockUserService()
        mock.fetchUserReturnValue = User(name: "Alice")

        let viewModel = ViewModel(service: mock)
        viewModel.fetchUser(id: 1)

        XCTAssertTrue(mock.fetchUserCalled)
        XCTAssertEqual(viewModel.userName, "Alice")
    }
}
```

### Swift Testing with Mock

```swift
// Same mock protocol
protocol UserService {
    func fetchUser(id: Int) -> User?
}

// Same mock implementation
final class MockUserService: UserService {
    var fetchUserCalled = false
    var fetchUserReturnValue: User?

    func fetchUser(id: Int) -> User? {
        fetchUserCalled = true
        return fetchUserReturnValue
    }
}

// Swift Testing test
@Suite
struct ViewModelTests {
    @Test
    func fetchUser() {
        let mock = MockUserService()
        mock.fetchUserReturnValue = User(name: "Alice")

        let viewModel = ViewModel(service: mock)
        viewModel.fetchUser(id: 1)

        #expect(mock.fetchUserCalled)
        #expect(viewModel.userName == "Alice")
    }
}
```

### Project-Specific: @Mocked Macro

```swift
// Using @Mocked macro
@Mocked
protocol UserService {
    func fetchUser(id: Int) async -> User?
}

@Suite
struct ViewModelTests {
    @Test
    func fetchUser() async {
        let mock = UserServiceMock()
        mock.fetchUserReturnValue = User(name: "Alice")

        let viewModel = ViewModel(service: mock)
        await viewModel.fetchUser(id: 1)

        #expect(viewModel.userName == "Alice")
    }
}
```

## Common Patterns

### Parameterized Tests

```swift
// XCTest - Manual loop
func testMultipleInputs() {
    let inputs = [1, 2, 3, 4, 5]
    for input in inputs {
        let result = double(input)
        XCTAssertEqual(result, input * 2)
    }
}

// Swift Testing - Built-in
@Test(arguments: [1, 2, 3, 4, 5])
func multipleInputs(input: Int) {
    let result = double(input)
    #expect(result == input * 2)
}
```

### Test with Multiple Assertions

```swift
// XCTest
func testUserValidation() {
    let user = User(name: "Alice", age: 25, email: "alice@example.com")

    XCTAssertEqual(user.name, "Alice")
    XCTAssertEqual(user.age, 25)
    XCTAssertTrue(user.email.contains("@"))
    XCTAssertFalse(user.isDeleted)
}

// Swift Testing
@Test
func userValidation() {
    let user = User(name: "Alice", age: 25, email: "alice@example.com")

    #expect(user.name == "Alice")
    #expect(user.age == 25)
    #expect(user.email.contains("@"))
    #expect(!user.isDeleted)
}
```

### Skipping Tests

```swift
// XCTest
func testFeature() throws {
    try XCTSkipIf(true, "Feature not implemented")
    // Test code
}

// Swift Testing
@Test(.disabled("Feature not implemented"))
func feature() {
    // Test code
}
```

### Performance Tests

```swift
// XCTest
func testPerformance() {
    measure {
        performExpensiveOperation()
    }
}

// Swift Testing
@Test(.timeLimit(.seconds(1)))
func performance() {
    performExpensiveOperation()
}
```

## Edge Cases

### Testing Throws vs Doesn't Throw

```swift
// XCTest
func testValidInput() {
    XCTAssertNoThrow(try validate(validInput))
}

func testInvalidInput() {
    XCTAssertThrowsError(try validate(invalidInput))
}

// Swift Testing
@Test
func validInput() throws {
    try validate(validInput)
    // If it throws, test fails
}

@Test
func invalidInput() {
    #expect(throws: ValidationError.self) {
        try validate(invalidInput)
    }
}
```

### Main Actor Tests

```swift
// XCTest
@MainActor
func testMainActorCode() async {
    let viewModel = ViewModel()
    await viewModel.load()
    XCTAssertTrue(viewModel.isLoaded)
}

// Swift Testing
@Test
@MainActor
func mainActorCode() async {
    let viewModel = ViewModel()
    await viewModel.load()
    #expect(viewModel.isLoaded)
}
```

### Custom Messages

```swift
// XCTest
XCTAssertEqual(result, expected, "Result \(result) doesn't match expected \(expected)")

// Swift Testing
#expect(result == expected, "Result \(result) doesn't match expected \(expected)")
```

### Accuracy Assertions (Floating Point)

```swift
// XCTest
XCTAssertEqual(result, 3.14159, accuracy: 0.001)

// Swift Testing
#expect(abs(result - 3.14159) < 0.001)
```

## Migration Checklist

When migrating a test file:

- [ ] Change `final class` to `@Suite struct`
- [ ] Remove `: XCTestCase` inheritance
- [ ] Convert `setUp()` to `init()`
- [ ] Convert `tearDown()` to `deinit` (if needed)
- [ ] Remove `test` prefix from method names
- [ ] Add `@Test` attribute to each test
- [ ] Add descriptive labels to `@Test`
- [ ] Replace all `XCTAssert*` with `#expect()`
- [ ] Replace `XCTUnwrap` with `#require`
- [ ] Convert async tests (remove expectations)
- [ ] Update import: `import Testing`
- [ ] Keep `@testable import` if needed
- [ ] Run tests to verify migration
- [ ] Update any mocks if necessary

## Summary

Key migration patterns:

1. **Structure**: Class → Struct with `@Suite`
2. **Tests**: `testXxx()` → `@Test func xxx()`
3. **Assertions**: `XCTAssertEqual(a, b)` → `#expect(a == b)`
4. **Async**: Remove expectations, use `async`
5. **Setup**: `setUp()` → `init()`
6. **Teardown**: `tearDown()` → `deinit`
7. **Unwrap**: `XCTUnwrap()` → `#require()`
8. **Parameterized**: Manual loops → `@Test(arguments:)`

Swift Testing simplifies test code and removes boilerplate while maintaining full testing capabilities.
