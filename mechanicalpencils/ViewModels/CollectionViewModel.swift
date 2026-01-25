//
//  CollectionViewModel.swift
//  mechanicalpencils
//

import Foundation
import Combine

@MainActor
class CollectionViewModel: ObservableObject {
    @Published var items: [CollectionItem] = []
    @Published var itemGroups: [ItemGroup] = []
    @Published var totalCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func fetchCollection() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchCollection()
            items = response.items
            itemGroups = response.itemGroups
            totalCount = response.totalCount
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func uploadProof(ownershipId: Int, imageData: Data) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await apiClient.uploadProof(ownershipId: ownershipId, imageData: imageData)
            // Refresh collection to get updated proof status
            await fetchCollection()
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        return false
    }
}
