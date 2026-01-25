//
//  Collection.swift
//  mechanicalpencils
//

import Foundation

struct CollectionItem: Codable, Identifiable {
    let id: Int
    let title: String
    let maker: String?
    let modelNumber: String?
    let imageUrl: String?
    let ownershipId: Int?
    let hasProof: Bool
    let proofUrl: String?
    let ownedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, maker
        case modelNumber = "model_number"
        case imageUrl = "image_url"
        case ownershipId = "ownership_id"
        case hasProof = "has_proof"
        case proofUrl = "proof_url"
        case ownedAt = "owned_at"
    }
}

struct CollectionResponse: Codable {
    let items: [CollectionItem]
    let itemGroups: [ItemGroup]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case items
        case itemGroups = "item_groups"
        case totalCount = "total_count"
    }
}
