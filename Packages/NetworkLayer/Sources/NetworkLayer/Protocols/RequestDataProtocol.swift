//
//  RequestDataProtocol.swift
//  FetchTakeHomeProject
//
//  Created by Gokul P on 1/30/25.
//

import Foundation

/// Protocol for managing the data for the URL reqeust
public protocol RequestDataProtocol {

    /// Request method type
    var method: RequestMethod { get }

    /// Scheme of the request url
    var scheme: String { get }

    /// Request end point
    var endPoint: String { get }

    /// Get authentication required or not for the request to set the
    /// authorization header
    var isAuthRequired: Bool { get }

    /// Request params
    var params: [String: Any]? { get }

    /// Header values for request
    var header: [String: String]? { get }

    /// Host for the end point
    var host: String { get }

    /// Query params that should be part of the url requests
    var queryParams: [String: String]? { get }
}

public extension RequestDataProtocol {

    // MARK: Default values

    var scheme: String {
        "https"
    }

    var queryParams: [String: String]? {
        nil
    }

    var header: [String: String]? {
        nil
    }

    var params: [String: Any]? {
        nil
    }

    var isAuthRequired: Bool {
        false
    }
}
