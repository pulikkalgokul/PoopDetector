//
//  APIError.swift
//  FetchTakeHomeProject
//
//  Created by Gokul P on 1/30/25.
//

import Foundation

/// A value to represent different types of errors that can occur during a network request.
public enum APIError: Error {
    /// error when JSON decoding fails
    case decode

    /// failed to get response from the end point
    case failedToGetResponse

    /// failed to get successful response from the end point
    case errorResponse

    /// the request is invalid. Due to some bad request parameter value
    case invalidRequest

    /// message for the error
    var customMessage: String {
        switch self {
        case .decode:
            "Decode error"
        case .invalidRequest:
            "Error in creating the request object"
        case .failedToGetResponse:
            "Error in receiving response from remote"
        case .errorResponse:
            "Got a non success response code from remote"
        }
    }
}
