//
//  HTTPClientProtocol.swift
//  FetchTakeHomeProject
//
//  Created by Gokul P on 1/30/25.
//

import Foundation

/// A protocol for the types that manages the API requests
public protocol HTTPClientProtocol: Sendable {

    /// function declaration that makes the API call and returns the Data
    func httpData(from requestData: RequestDataProtocol) async throws -> Data

    /// function declaration that will return URL request by processing the requestData of type `RequestDataProtocol`
    func getRequest(requestData: RequestDataProtocol) throws -> URLRequest

}

extension HTTPClientProtocol {
    // MARK: Default implementations

    /// Default implementations for the URL request creation from the request data
    /// This can be overridden but most of the time this will suffice
    public func getRequest(requestData: RequestDataProtocol) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = requestData.scheme
        urlComponents.host = requestData.host
        urlComponents.path = requestData.endPoint

        if let queryParams = requestData.queryParams {
            var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
            queryParams.keys.forEach { key in
                if let value = queryParams[key] {
                    let queryItem = URLQueryItem(name: key, value: value)
                    queryItems.append(queryItem)
                }
            }
            urlComponents.queryItems = queryItems
        }

        // Ensure that the URL can be constructed
        guard let url = urlComponents.url else {
            throw APIError.invalidRequest
        }

        // Create a URLRequest using the constructed URL and the HTTP method and headers from the requestType
        var request = URLRequest(url: url)
        request.httpMethod = requestData.method.rawValue
        request.allHTTPHeaderFields = requestData.header

        if let body = requestData.params {
            let serializedBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = serializedBody
        }

        return request
    }
}
