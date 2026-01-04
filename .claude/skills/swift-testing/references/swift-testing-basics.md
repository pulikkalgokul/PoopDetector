# Swift Testing Basics

Comprehensive guide to Swift Testing framework syntax, features, and concepts.

## Table of Contents

1. [Introduction](#introduction)
2. [Basic Syntax](#basic-syntax)
3. [Test Suites](#test-suites)
4. [Assertions](#assertions)
5. [Async Testing](#async-testing)
6. [Parameterized Tests](#parameterized-tests)
7. [Test Lifecycle](#test-lifecycle)
8. [Test Tags](#test-tags)
9. [Test Conditions](#test-conditions)
10. [Advanced Features](#advanced-features)

## Introduction

Swift Testing is Apple's modern testing framework introduced in Swift 5.9. It provides:

- **Type-safe assertions**: Compile-time checking of test conditions
- **Natural async/await support**: No more expectations or wait calls
- **Expressive syntax**: Clear, readable test code
- **Parameterized testing**: Test multiple inputs easily
- **Suite organization**: Group related tests logically
- **Better error messages**: Clear failure descriptions

## Basic Syntax

### Simple Test

```swift
import Testing
@testable import MyModule

@Test
func addition() {
    let result = 2 + 2
    #expect(result == 4)
}
```

### Test with Label

```swift
@Test("Addition produces correct sum")
func addition() {
    let result = 2 + 2
    #expect(result == 4)
}
```

Labels appear in test output and make test purpose clear.

### Test with Custom Message

```swift
@Test
func arrayCount() {
    let items = [1, 2, 3]
    #expect(items.count == 3, "Expected 3 items, got \(items.count)")
}
```

## Test Suites

### Basic Suite

```swift
@Suite("Math Operations")
struct MathTests {
    @Test func addition() {
        #expect(2 + 2 == 4)
    }

    @Test func subtraction() {
        #expect(5 - 3 == 2)
    }
}
```

### Nested Suites

```swift
@Suite("Calculator")
struct CalculatorTests {
    @Suite("Basic Operations")
    struct BasicOperations {
        @Test func addition() { }
        @Test func subtraction() { }
    }

    @Suite("Advanced Operations")
    struct AdvancedOperations {
        @Test func power() { }
        @Test func root() { }
    }
}
```

### Suite with Shared State

```swift
@Suite
struct DatabaseTests {
    let database: Database

    init() {
        database = Database(inMemory: true)
    }

    @Test
    func insertUser() {
        database.insert(User(name: "Alice"))
        #expect(database.users.count == 1)
    }

    @Test
    func deleteUser() {
        let user = User(name: "Bob")
        database.insert(user)
        database.delete(user)
        #expect(database.users.isEmpty)
    }
}
```

Each test gets a fresh instance with its own `database`.

## Assertions

### expect()

The primary assertion macro for Swift Testing.

#### Boolean Conditions

```swift
@Test
func booleanConditions() {
    #expect(true)
    #expect(2 > 1)
    #expect(!false)
    #expect("hello".isEmpty == false)
}
```

#### Equality

```swift
@Test
func equality() {
    #expect(2 + 2 == 4)
    #expect("hello" == "hello")
    #expect([1, 2, 3] == [1, 2, 3])
}
```

#### Inequality

```swift
@Test
func inequality() {
    #expect(5 != 3)
    #expect("hello" != "world")
}
```

#### Comparisons

```swift
@Test
func comparisons() {
    #expect(5 > 3)
    #expect(2 < 10)
    #expect(5 >= 5)
    #expect(3 <= 3)
}
```

#### Optionals

```swift
@Test
func optionals() {
    let value: Int? = 42
    #expect(value != nil)
    #expect(value == 42)

    let nilValue: Int? = nil
    #expect(nilValue == nil)
}
```

### require()

Use `#require()` to unwrap optionals and stop test if nil:

```swift
@Test
func unwrapping() throws {
    let value: Int? = 42
    let unwrapped = try #require(value)
    #expect(unwrapped == 42)
}
```

If `value` is nil, the test stops with a failure. The rest of the test doesn't run.

### expect(throws:)

Assert that code throws an error:

```swift
@Test
func throwsError() {
    #expect(throws: NetworkError.self) {
        try performNetworkRequest()
    }
}
```

Assert specific error:

```swift
@Test
func throwsSpecificError() {
    #expect(throws: NetworkError.timeout) {
        try performNetworkRequest()
    }
}
```

### Custom Messages

All assertions support custom messages:

```swift
@Test
func customMessage() {
    let items = fetchItems()
    #expect(items.count == 5, "Expected 5 items, got \(items.count)")
}
```

## Async Testing

### Basic Async Test

```swift
@Test
func asyncOperation() async {
    let result = await fetchData()
    #expect(result.isEmpty == false)
}
```

No expectations or waiting needed - just use `async`.

### Async with Throws

```swift
@Test
func asyncThrows() async throws {
    let result = try await fetchDataThatMightFail()
    #expect(result.isValid)
}
```

### Testing Async Sequences

```swift
@Test
func asyncSequence() async {
    var values: [Int] = []
    for await value in generateSequence() {
        values.append(value)
    }
    #expect(values == [1, 2, 3, 4, 5])
}
```

### Concurrent Operations

```swift
@Test
func concurrentOperations() async {
    async let result1 = fetchData(from: "url1")
    async let result2 = fetchData(from: "url2")

    let (data1, data2) = await (result1, result2)

    #expect(data1.count > 0)
    #expect(data2.count > 0)
}
```

## Parameterized Tests

### Single Parameter

```swift
@Test(arguments: [1, 2, 3, 4, 5])
func isEven(number: Int) {
    let result = number % 2 == 0
    #expect(result == (number % 2 == 0))
}
```

Runs 5 separate tests, one for each argument.

### Multiple Parameters

```swift
@Test(arguments: [
    (2, 3, 5),
    (5, 7, 12),
    (10, 15, 25)
])
func addition(a: Int, b: Int, expected: Int) {
    #expect(a + b == expected)
}
```

### Parameter Arrays

```swift
@Test(arguments: [
    ["apple", "banana"],
    ["cat", "dog", "elephant"],
    []
])
func arrayCount(items: [String]) {
    if items.isEmpty {
        #expect(items.count == 0)
    } else {
        #expect(items.count > 0)
    }
}
```

### Combining Parameters

```swift
@Test(arguments: [true, false], [1, 2, 3])
func combination(flag: Bool, number: Int) {
    // Tests all combinations: (true, 1), (true, 2), (true, 3),
    //                         (false, 1), (false, 2), (false, 3)
    if flag {
        #expect(number > 0)
    }
}
```

### Custom Collections

```swift
enum Status: CaseIterable {
    case active, inactive, pending
}

@Test(arguments: Status.allCases)
func statusHandling(status: Status) {
    let message = formatStatus(status)
    #expect(!message.isEmpty)
}
```

## Test Lifecycle

### Per-Test Setup/Teardown

Use `init()` and `deinit`:

```swift
@Suite
struct DatabaseTests {
    let database: Database

    init() {
        print("Setting up database")
        database = Database(inMemory: true)
        database.migrate()
    }

    deinit {
        print("Tearing down database")
        database.close()
    }

    @Test
    func test1() {
        // Fresh database instance
    }

    @Test
    func test2() {
        // Another fresh database instance
    }
}
```

Each test gets its own instance, so `init()` and `deinit()` run for each test.

### Shared Setup (Suite-Level)

For setup that should run once per suite:

```swift
@Suite
struct APITests {
    static let apiClient: APIClient = {
        let client = APIClient()
        client.configure()
        return client
    }()

    @Test
    func test1() {
        // Uses shared apiClient
    }

    @Test
    func test2() {
        // Uses same shared apiClient
    }
}
```

## Test Tags

Use tags to categorize and filter tests:

```swift
@Test(.tags(.integration))
func integrationTest() {
    // Integration test logic
}

@Test(.tags(.unit, .smoke))
func smokeTest() {
    // Smoke test logic
}
```

Define custom tags:

```swift
extension Tag {
    @Tag static var integration: Self
    @Tag static var unit: Self
    @Tag static var smoke: Self
    @Tag static var slow: Self
}
```

Run tests by tag:

```bash
swift test --filter tag:integration
swift test --filter tag:unit
```

## Test Conditions

### Platform-Specific Tests

```swift
@Test(.enabled(if: ProcessInfo.processInfo.isiOSAppOnMac))
func macCatalystSpecific() {
    // Only runs on Mac Catalyst
}

@Test(.enabled(if: ProcessInfo.processInfo.environment["CI"] != nil))
func ciOnlyTest() {
    // Only runs in CI environment
}
```

### Disabled Tests

```swift
@Test(.disabled("Temporarily disabled due to bug #123"))
func flakyTest() {
    // Test code
}
```

### Known Issues

```swift
@Test(.bug("https://github.com/owner/repo/issues/456"))
func testWithKnownIssue() {
    // Test that fails due to known bug
}
```

## Advanced Features

### Test with Timeout

```swift
@Test(.timeLimit(.minutes(1)))
func longRunningTest() async {
    await performLongOperation()
}
```

### Serial Execution

By default, tests run in parallel. Force serial execution:

```swift
@Suite(.serialized)
struct SerialTests {
    @Test func first() { }
    @Test func second() { }
    @Test func third() { }
}
```

Tests run one at a time in order.

### Repeated Tests

Run a test multiple times:

```swift
@Test(arguments: 1...100)
func stressTest(iteration: Int) {
    let result = performOperation()
    #expect(result.isValid)
}
```

### Custom Test Arguments

Provide custom argument descriptions:

```swift
struct User {
    let name: String
}

extension User: CustomTestStringConvertible {
    var testDescription: String { "User(\(name))" }
}

@Test(arguments: [User(name: "Alice"), User(name: "Bob")])
func userTest(user: User) {
    #expect(!user.name.isEmpty)
}
```

### Before/After Hooks

```swift
@Suite
struct HookTests {
    init() {
        // Runs before each test
        print("Before test")
    }

    deinit {
        // Runs after each test
        print("After test")
    }

    @Test
    func test1() {
        print("Test 1")
    }

    @Test
    func test2() {
        print("Test 2")
    }
}

// Output:
// Before test
// Test 1
// After test
// Before test
// Test 2
// After test
```

## Comparison with XCTest

| Feature | XCTest | Swift Testing |
|---------|--------|---------------|
| Test class | Inherit `XCTestCase` | Use `@Suite` struct |
| Test method | Prefix with `test` | Use `@Test` attribute |
| Assertion | `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| Async testing | Expectations + wait | `async` function |
| Parameterized | Manual loops | `@Test(arguments:)` |
| Setup | `setUp()` method | `init()` |
| Teardown | `tearDown()` method | `deinit` |
| Optional unwrap | `XCTUnwrap()` | `#require()` |

## Summary

Swift Testing provides:
- **Simple syntax**: `@Test` and `@Suite` for organization
- **Type-safe assertions**: `#expect()` with compile-time checking
- **Natural async**: Use `async`/`await` directly
- **Parameterized tests**: Test multiple inputs easily
- **Flexible lifecycle**: `init()`/`deinit()` for setup/teardown
- **Tags and conditions**: Filter and control test execution
- **Better errors**: Clear, actionable failure messages

Swift Testing modernizes testing in Swift with a cleaner, more expressive API.
