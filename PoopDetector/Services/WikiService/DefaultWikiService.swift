//
//  DefaultWikiService.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation
import NetworkLayer

struct DefaultWikiService: WikiServiceProtocol {
    // MARK: - Properties

    /// httpClient dependency to retrieve recipes from the remote endpoint
    let httpClient: HTTPClientProtocol

    // MARK: - Init

    init(httpClient: HTTPClientProtocol = HTTPClient()) {
        self.httpClient = httpClient
    }

    /// Function that will return the wiki data for the  available from the endpoint
    func wikiData(for scientificName: String) async throws -> WikiAPIResponseDTO {
        let wikiRequestData = WikiDataRequests.speciesData(speciesName: scientificName)
        let data = try await httpClient.httpData(from: wikiRequestData)
        let wikiResponse = try JSONDecoder().decode(WikiAPIResponseDTO.self, from: data)
        return wikiResponse
    }
}
