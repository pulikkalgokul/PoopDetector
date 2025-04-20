//
//  HTTPClient.swift
//  FetchTakeHomeProject
//
//  Created by Gokul P on 1/30/25.
//

import Foundation

// MARK: - URLSession + HTTPClientProtocol

/// The client that can be used for API calls and any network related calls
public final class HTTPClient: HTTPClientProtocol {
    // MARK: Properties

    /// URL session to be used for the API call
    private let session: URLSession

    // MARK: Initializer

    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    // MARK: Functions

    /// function that makes the URL request from request data and then makes the API call and returns the Data
    public func httpData(from requestData: RequestDataProtocol) async throws -> Data {
        let request = try getRequest(requestData: requestData)

        guard let (data, response) = try await session.data(for: request) as? (Data, HTTPURLResponse) else {
            throw APIError.failedToGetResponse
        }
        switch response.statusCode {
        case 200...299:
            return data
        default:
            throw APIError.errorResponse
        }
    }
}
