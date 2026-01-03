//
//  WikiDataRequest.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation
import NetworkLayer

/// A type that specifies all the needed fields for URL request creation for the WikiData API.
enum WikiDataRequests: RequestDataProtocol {

    /// for the end point to fetch species data.
    case speciesData(speciesName: String)

    var method: RequestMethod {
        switch self {
        case .speciesData:
            .get
        }
    }

    var endPoint: String {
        switch self {
        case let .speciesData(speciesName):
            "/api/rest_v1/page/summary/\(speciesName)"
        }
    }

    var host: String {
        switch self {
        case .speciesData:
            "en.wikipedia.org"
        }
    }
}
