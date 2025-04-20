//
//  RequestDataMock.swift
//  FetchTakeHomeProjectTests
//
//  Created by Gokul P on 1/30/25.
//

import Foundation
@testable import NetworkLayer

enum RequestDataMock: RequestDataProtocol {

    case requestDataSuccess
    case requestDataFailure

    var method: RequestMethod {
        switch self {
        case .requestDataSuccess:
            .get
        case .requestDataFailure:
            .get
        }
    }

    var host: String {
        switch self {
        case .requestDataSuccess:
            "www.apple.com"
        case .requestDataFailure:
            "e.com"
        }
    }

    var endPoint: String {
        switch self {
        case .requestDataSuccess:
            "/newsroom/rss-feed.rss"
        case .requestDataFailure:
            "d/two.rss"
        }
    }

    var params: [String: Any]? {
        switch self {
        case .requestDataSuccess,
             .requestDataFailure:
            [
                "This is test paramOne": 1,
                "this is test paramTWO": "Two"
            ]
        }
    }

    var header: [String: String]? {
        switch self {
        case .requestDataSuccess:
            [
                "This is test HeaderONE": "1",
                "this is test HeaderTWO": "Two"
            ]
        case .requestDataFailure:
            nil
        }
    }

    var queryParams: [String: String]? {
        switch self {
        case .requestDataSuccess:
            [
                "This is test queryParamONE": "1",
                "this is test queryParamTWO": "Two"
            ]
        case .requestDataFailure:
            nil
        }
    }

}
