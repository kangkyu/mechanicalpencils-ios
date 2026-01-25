//
//  ItemGroup.swift
//  mechanicalpencils
//

import Foundation

struct ItemGroup: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let link: String?
    let itemsCount: Int?
    let items: [Item]?

    enum CodingKeys: String, CodingKey {
        case id, title, link, items
        case itemsCount = "items_count"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ItemGroup, rhs: ItemGroup) -> Bool {
        lhs.id == rhs.id
    }
}

struct ItemGroupsResponse: Codable {
    let itemGroups: [ItemGroup]

    enum CodingKeys: String, CodingKey {
        case itemGroups = "item_groups"
    }
}

struct ItemGroupResponse: Codable {
    let itemGroup: ItemGroup

    enum CodingKeys: String, CodingKey {
        case itemGroup = "item_group"
    }
}
