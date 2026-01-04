---
name: Swift Testing
description: Writes, migrates, and debugs Swift tests using Apple's modern Testing framework. Use when writing tests, migrating from XCTest, or when the user mentions Swift Testing, test migration, or fixing test failures.
---

# Swift Testing Skill

Swift Testing is Apple's modern testing framework that provides a more expressive, type-safe approach to testing compared to XCTest.

## Quick Start

| Feature | XCTest | Swift Testing |
|---------|--------|---------------|
| Test declaration | `func testName()` in `XCTestCase` subclass | `@Test func name()` in struct |
| Assertions | `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| Async testing | Expectations + `wait(for:)` | `async` function |

## Project Conventions

- Use `@Suite` to organize tests
- Place tests in `Tests/` directory within module
- Use 5.0 second timeout for fulfillment when needed
- Mock dependencies with `@Mocked` protocol

## Additional Resources

### Reference Files

For detailed guidance with comprehensive examples, consult:
- **`references/swift-testing-basics.md`** - Complete Swift Testing syntax, features, and code examples
- **`references/testing-best-practices.md`** - Best practices, patterns, debugging strategies, and common pitfalls
- **`references/xctest-migration.md`** - Detailed XCTest to Swift Testing migration patterns with before/after examples
