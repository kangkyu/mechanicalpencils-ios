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
