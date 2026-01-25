//
//  Item.swift
//  mechanicalpencils
//

import Foundation

struct Item: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let maker: String?
    let modelNumber: String?
    let imageUrl: String?
    let owned: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, maker, owned
        case modelNumber = "model_number"
        case imageUrl = "image_url"
    }
}

struct ItemDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let maker: Maker?
    let modelNumber: String?
    let tipRetractable: String?
    let eraserAttached: String?
    let jetpensUrl: String?
    let blickUrl: String?
    let imageUrl: String?
    let thumbnailUrl: String?
    let owned: Bool
    let hasProof: Bool
    let ownershipId: Int?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, maker, owned
        case modelNumber = "model_number"
        case tipRetractable = "tip_retractable"
        case eraserAttached = "eraser_attached"
        case jetpensUrl = "jetpens_url"
        case blickUrl = "blick_url"
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case hasProof = "has_proof"
        case ownershipId = "ownership_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ItemsResponse: Codable {
    let items: [Item]
    let pagination: Pagination
}

struct ItemResponse: Codable {
    let item: ItemDetail
    let message: String?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let perPage: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
        case perPage = "per_page"
    }
}
