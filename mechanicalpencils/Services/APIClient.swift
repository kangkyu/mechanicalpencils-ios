//
//  APIClient.swift
//  mechanicalpencils
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Please log in to continue"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://mechanical-pencils-bab056ce6286.herokuapp.com"

    private let keychain = KeychainManager.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private init() {}

    // MARK: - Auth

    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        let response: AuthResponse = try await request(.login, body: body)
        keychain.saveToken(response.token)
        return response
    }

    func register(email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]

        let response: AuthResponse = try await request(.register, body: body)
        keychain.saveToken(response.token)
        return response
    }

    func logout() async throws {
        let _: MessageResponse = try await request(.logout)
        keychain.deleteToken()
    }

    // MARK: - Items

    func fetchItems(page: Int = 1, search: String? = nil) async throws -> ItemsResponse {
        try await request(.items(page: page, search: search))
    }

    func fetchItem(id: Int) async throws -> ItemResponse {
        try await request(.item(id: id))
    }

    func ownItem(id: Int) async throws -> ItemResponse {
        try await request(.own(itemId: id))
    }

    func unownItem(id: Int) async throws -> ItemResponse {
        try await request(.unown(itemId: id))
    }

    // MARK: - Collection

    func fetchCollection() async throws -> CollectionResponse {
        try await request(.collection)
    }

    func uploadProof(ownershipId: Int, imageData: Data) async throws -> OwnershipResponse {
        try await uploadMultipart(.uploadProof(ownershipId: ownershipId), imageData: imageData)
    }

    // MARK: - Makers & Groups

    func fetchMakers() async throws -> MakersResponse {
        try await request(.makers)
    }

    func fetchItemGroups() async throws -> ItemGroupsResponse {
        try await request(.itemGroups)
    }

    func fetchItemGroup(id: Int) async throws -> ItemGroupResponse {
        try await request(.itemGroup(id: id))
    }

    // MARK: - Private Helpers

    private func request<T: Decodable>(_ endpoint: APIEndpoint, body: [String: Any]? = nil) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = keychain.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                keychain.deleteToken()
                throw APIError.unauthorized
            default:
                if let errorResponse = try? decoder.decode(AuthError.self, from: data) {
                    let message = errorResponse.error ?? errorResponse.errors?.joined(separator: ", ") ?? "Unknown error"
                    throw APIError.serverError(message)
                }
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func uploadMultipart<T: Decodable>(_ endpoint: APIEndpoint, imageData: Data) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = keychain.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"proof\"; filename=\"proof.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(T.self, from: data)
            case 401:
                keychain.deleteToken()
                throw APIError.unauthorized
            default:
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

struct MessageResponse: Codable {
    let message: String
}
