//
//  WikiServiceProtocol.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation

protocol WikiServiceProtocol {
    func wikiData(for scientificName: String) async throws -> WikiAPIResponseDTO
}
