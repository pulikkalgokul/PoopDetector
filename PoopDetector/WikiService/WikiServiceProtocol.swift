//
//  WikiServiceProtocol.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation

protocol WikiServiceProtocol: Sendable {
    func wikiData(for scientificName: String) async throws -> WikiAPIResponseDTO
}
