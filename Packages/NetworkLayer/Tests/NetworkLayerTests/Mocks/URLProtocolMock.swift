//
//  URLProtocolMock.swift
//  FetchTakeHomeProjectTests
//
//  Created by Gokul P on 1/30/25.
//

import Foundation

class URLProtocolMock: URLProtocol {

    /// Unsafe access to loading handler is permitted only for testing. Make sure that tests using this property runs
    /// sequentially
    nonisolated(unsafe) static var loadingHandler: (() -> (HTTPURLResponse, Data?))?

    /// say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    /// ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.loadingHandler else {
            fatalError("Loading handler is not set.")
        }

        let (response, data) = handler()
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    /// this method is required but doesn't need to do anything
    override func stopLoading() {}
}
