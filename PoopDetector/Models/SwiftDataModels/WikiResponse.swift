//
//  WikiResponse.swift
//  PoopDetector
//
//  Created by Gokul P on 4/20/25.
//

import Foundation
import SwiftData

@Model
final class WikiResponse: Decodable {
    var title: String
    var thumbnail: ImageInfo
    var originalImage: ImageInfo
    var contentUrls: ContentURLInfo
    var extract: String

    init(title: String, thumbnail: ImageInfo, originalimage: ImageInfo, content_urls: ContentURLInfo, extract: String) {
        self.title = title
        self.thumbnail = thumbnail
        self.originalImage = originalimage
        self.contentUrls = content_urls
        self.extract = extract
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case thumbnail
        case originalImage = "originalimage"
        case contentUrls = "content_urls"
        case extract
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.thumbnail = try container.decode(ImageInfo.self, forKey: .thumbnail)
        self.originalImage = try container.decode(ImageInfo.self, forKey: .originalImage)
        self.contentUrls = try container.decode(ContentURLInfo.self, forKey: .contentUrls)
        self.extract = try container.decode(String.self, forKey: .extract)
    }

    init(wikiResponseDTO: WikiAPIResponseDTO) {
        self.title = wikiResponseDTO.title
        self.thumbnail = ImageInfo(imageInfoDTO: wikiResponseDTO.thumbnail)
        self.originalImage = ImageInfo(imageInfoDTO: wikiResponseDTO.originalImage)
        self.contentUrls = ContentURLInfo(contentURLInfoDTO: wikiResponseDTO.contentUrls)
        self.extract = wikiResponseDTO.extract
    }

}

@Model
final class ImageInfo: Decodable {
    var source: String
    var width: Int
    var height: Int

    init(source: String, width: Int, height: Int) {
        self.source = source
        self.width = width
        self.height = height
    }

    private enum CodingKeys: String, CodingKey {
        case source
        case width
        case height
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.source = try container.decode(String.self, forKey: .source)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
    }

    init(imageInfoDTO: ImageInfoDTO) {
        self.source = imageInfoDTO.source
        self.width = imageInfoDTO.width
        self.height = imageInfoDTO.height
    }
}

@Model
final class ContentURLInfo: Decodable {
    var mobile: Reference

    init(mobile: Reference) {
        self.mobile = mobile
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mobile = try container.decode(Reference.self, forKey: .mobile)
    }

    private enum CodingKeys: String, CodingKey {
        case mobile
    }

    init(contentURLInfoDTO: ContentURLInfoDTO) {
        self.mobile = Reference(referenceDTO: contentURLInfoDTO.mobile)
    }

}

@Model
final class Reference: Decodable {
    var page: String

    init(page: String) {
        self.page = page
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(String.self, forKey: .page)
    }

    private enum CodingKeys: String, CodingKey {
        case page
    }

    init(referenceDTO: ReferenceDTO) {
        self.page = referenceDTO.page
    }

}
