//
//  User.swift
//  mechanicalpencils
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let admin: Bool
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct AuthError: Codable {
    let error: String?
    let errors: [String]?
}

struct PublicUser: Codable, Identifiable {
    let id: Int
    let email: String
}

struct UserProfileItem: Codable, Identifiable {
    let id: Int
    let title: String
    let maker: String?
    let modelNumber: String?
    let imageUrl: String?
    let hasProof: Bool
    let proofUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, maker
        case modelNumber = "model_number"
        case imageUrl = "image_url"
        case hasProof = "has_proof"
        case proofUrl = "proof_url"
    }
}

struct UserProfileResponse: Codable {
    let user: PublicUser
    let items: [UserProfileItem]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case user, items
        case totalCount = "total_count"
    }
}
