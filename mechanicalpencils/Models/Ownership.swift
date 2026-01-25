//
//  Ownership.swift
//  mechanicalpencils
//

import Foundation

struct Ownership: Codable, Identifiable {
    let id: Int
    let itemId: Int
    let hasProof: Bool
    let proofUrl: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case hasProof = "has_proof"
        case proofUrl = "proof_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OwnershipResponse: Codable {
    let ownership: Ownership
    let message: String?
}
