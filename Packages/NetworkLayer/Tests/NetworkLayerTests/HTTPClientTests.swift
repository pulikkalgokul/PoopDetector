//
//  HTTPClientTests.swift
//  FetchTakeHomeProjectTests
//
//  Created by Gokul P on 1/30/25.
//

import Foundation
import Testing
@testable import NetworkLayer

@Suite(.serialized) // For preventing the data race condition that can happen on URLProtocolMock
struct HTTPClientTests {

    private let httpClient: HTTPClientProtocol

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession(configuration: config)
        self.httpClient = HTTPClient(session: urlSession)
    }

    @Test
    func requestCreationSuccess() async throws {
        let mockRequestData = RequestDataMock.requestDataSuccess
        let returnedRequest = try httpClient.getRequest(requestData: mockRequestData)
        #expect(mockRequestData.method.rawValue == returnedRequest.httpMethod)

        let url = try #require(returnedRequest.url)
        #expect(mockRequestData.scheme == url.scheme)
        #expect(mockRequestData.endPoint == url.path)
        #expect(mockRequestData.host == url.host)
        let returnedQueryItems = URLComponents(string: url.absoluteString)?.queryItems
        let returnedQueryParams: [String: String]? = returnedQueryItems?
            .reduce(into: [String: String]()) { result, item in
                result[item.name] = item.value
            }
        #expect(mockRequestData.queryParams as? NSDictionary == returnedQueryParams as? NSDictionary)

        if let params = mockRequestData.params {
            let returnedParams = try #require(JSONSerialization.jsonObject(
                with: returnedRequest.httpBody!,
                options: []
            ) as? [String: Any])
            #expect(params as NSDictionary == returnedParams as NSDictionary)
        }
        #expect(mockRequestData.header as? NSDictionary == returnedRequest.allHTTPHeaderFields  as? NSDictionary)
    }

    @Test
    func requestCreationFail() async throws {
        let malformedRequestData = RequestDataMock.requestDataFailure
        #expect(performing: {
            try httpClient.getRequest(requestData: malformedRequestData)
        }, throws: { error in
            APIError.invalidRequest.localizedDescription == error.localizedDescription
        })
    }

    @Test
    func httpClientSuccessfulDataReturn() async throws {
        let expectedData = "Hacking with Swift!".data(using: .utf8)
        URLProtocolMock.loadingHandler = {
            let response = HTTPURLResponse(
                url: URL(string: "www.google.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, expectedData)
        }
        let returnedData = try #require(await httpClient.httpData(from: RequestDataMock.requestDataSuccess))
        #expect(returnedData == expectedData)
    }

    @Test
    func httpClientSuccessWithNoResponseData() async throws {
        URLProtocolMock.loadingHandler = {
            let response = HTTPURLResponse(
                url: URL(string: "www.google.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, nil)
        }
        _ = try #require(try await httpClient.httpData(from: RequestDataMock.requestDataSuccess))
    }

    @Test
    func httpClientFailedWithErrorResponseCode() async throws {
        URLProtocolMock.loadingHandler = {
            let response = HTTPURLResponse(
                url: URL(string: "www.google.com")!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, nil)
        }

        await #expect(performing: {
            try await httpClient.httpData(from: RequestDataMock.requestDataSuccess)
        }, throws: { error in
            APIError.errorResponse.localizedDescription == error.localizedDescription
        })
    }

}
