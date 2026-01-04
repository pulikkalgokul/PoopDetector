## Example

```swift
@Mocked(compilationCondition: .debug)
protocol WeatherService {
    func currentTemperature(latitude: Double, longitude: Double) async throws -> Double
}
```

```swift
struct WeatherViewModelTests {
    @Test
    func loadCurrentTemperature() async {
        let weatherServiceMock = WeatherServiceMock()
        let viewModel = WeatherViewModel(weatherService: weatherServiceMock)

        // Set the dependency's implementation.
        weatherServiceMock._currentTemperature.implementation = .returns(75)

        // Invoke the method being tested.
        await viewModel.loadCurrentTemperature(latitude: 37.3349, longitude: 122.0090)

        // Validate the number of times the dependency was called.
        #expect(weatherServiceMock._currentTemperature.callCount == 1)

        // Validate the arguments passed to the dependency.
        #expect(weatherServiceMock._currentTemperature.lastInvocation?.latitude == 37.3349)
        #expect(weatherServiceMock._currentTemperature.lastInvocation?.longitude == 122.0090)

        // Validate the view model's new state.
        #expect(viewModel.state == .loaded(temperature: 75))
    }
}
```
