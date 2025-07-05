//
//  WikiAPIResponseDTO.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation

struct WikiAPIResponseDTO: Decodable, Hashable {
    let title: String
    let thumbnail: ImageInfoDTO
    let originalImage: ImageInfoDTO
    let contentUrls: ContentURLInfoDTO
    let extract: String

    private enum CodingKeys: String, CodingKey {
        case title
        case thumbnail
        case originalImage = "originalimage"
        case contentUrls = "content_urls"
        case extract
    }
}

struct ImageInfoDTO: Decodable, Hashable {
    let source: String
    let width: Int
    let height: Int

}

struct ContentURLInfoDTO: Decodable, Hashable {
    var mobile: ReferenceDTO
}

struct ReferenceDTO: Decodable, Hashable {
    let page: String
}
