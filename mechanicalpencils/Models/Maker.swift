//
//  Maker.swift
//  mechanicalpencils
//

import Foundation

struct Maker: Codable, Identifiable {
    let id: Int
    let title: String?
    let origin: String?
    let homepage: String?
    let itemsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, origin, homepage
        case itemsCount = "items_count"
    }
}

struct MakersResponse: Codable {
    let makers: [Maker]
}
