//
//  APIEndpoint.swift
//  mechanicalpencils
//

import Foundation

enum APIEndpoint {
    case login
    case logout
    case register
    case items(page: Int, search: String?)
    case item(id: Int)
    case own(itemId: Int)
    case unown(itemId: Int)
    case collection
    case uploadProof(ownershipId: Int)
    case makers
    case itemGroups
    case itemGroup(id: Int)

    var path: String {
        switch self {
        case .login:
            return "/api/v1/session"
        case .logout:
            return "/api/v1/session"
        case .register:
            return "/api/v1/registration"
        case .items:
            return "/api/v1/items"
        case .item(let id):
            return "/api/v1/items/\(id)"
        case .own(let itemId):
            return "/api/v1/items/\(itemId)/own"
        case .unown(let itemId):
            return "/api/v1/items/\(itemId)/unown"
        case .collection:
            return "/api/v1/collection"
        case .uploadProof(let ownershipId):
            return "/api/v1/ownerships/\(ownershipId)"
        case .makers:
            return "/api/v1/makers"
        case .itemGroups:
            return "/api/v1/item_groups"
        case .itemGroup(let id):
            return "/api/v1/item_groups/\(id)"
        }
    }

    var method: String {
        switch self {
        case .login, .register, .own:
            return "POST"
        case .logout, .unown:
            return "DELETE"
        case .uploadProof:
            return "PATCH"
        default:
            return "GET"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .items(let page, let search):
            var items = [URLQueryItem(name: "page", value: "\(page)")]
            if let search = search, !search.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
            return items
        default:
            return nil
        }
    }
}
