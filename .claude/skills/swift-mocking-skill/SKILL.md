---
name: swift-mocking
description: This skill should be used when the user asks to "create a mock", "generate a mock", "use @Mocked macro", "mock a protocol", "write test mocks", mentions "Swift Mocking library", asks about "@MockedMembers", "@MockableProperty", or "@MockableMethod" macros, or needs guidance on protocol mocking for unit tests in Swift.
version: 1.0.0
---

# Swift Mocking

Swift Mocking is a macro library that automatically generates type-safe, concurrency-safe mock implementations from protocol declarations for unit testing.

## Quick Start

| Aspect | Implementation |
|--------|----------------|
| Apply macro | `@Mocked(compilationCondition: .debug)` on protocol |
| Generated mock | `{Protocol}Mock` class with backing properties |
| Set behavior | `mock._method.implementation = .returns(value)` |
| Verify calls | `#expect(mock._method.callCount == 1)` |
| Check arguments | `#expect(mock._method.lastInvocation?.arg == expected)` |

## Basic Usage

```swift
@Mocked(compilationCondition: .debug)
protocol WeatherService {
    func currentTemperature(latitude: Double, longitude: Double) async throws -> Double
}

// In tests
let mock = WeatherServiceMock()
mock._currentTemperature.implementation = .returns(75)
#expect(mock._currentTemperature.callCount == 1)
```

## Project Conventions

- Use `@Mocked(compilationCondition: .debug)` for one-step usage
- Import `Mocking` in test files
- Configure behavior via backing properties (`_methodName`)
- Verify both call counts and arguments
- Use checked implementation constructors (`.returns()`, `.invokes()`) for Sendable types
- Use unchecked variants (`.uncheckedReturns()`, `.uncheckedInvokes()`) only for non-Sendable types
- Reset static members between tests with `resetMockedStaticMembers()`
- For protocols with inheritance, use `@MockedMembers` with manual declaration

## Additional Resources

### Reference Files

For comprehensive guidance with detailed examples, consult:

- **`references/swift-mocking-basics.md`** - Complete usage guide, installation, compilation conditions, implementation constructors, and common patterns
- **`references/best-practices.md`** - Best practices, advanced patterns, debugging strategies, common pitfalls, and testing strategies
- **`references/macros.md`** - Detailed macro documentation for `@Mocked`, `@MockedMembers`, `@MockableProperty`, `@MockableMethod`
- **`references/features.md`** - Complete list of supported Swift features (actors, async/await, associated types, etc.)
- **`references/usage.md`** - Backing property API reference

### Examples

- **`examples/example.md`** - Working weather service example with test implementation
