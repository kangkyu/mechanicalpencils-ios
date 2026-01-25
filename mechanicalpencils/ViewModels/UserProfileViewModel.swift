//
//  UserProfileViewModel.swift
//  mechanicalpencils
//

import Foundation
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: PublicUser?
    @Published var items: [UserProfileItem] = []
    @Published var totalCount = 0
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func fetchUserProfile(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchUserProfile(id: id)
            user = response.user
            items = response.items
            totalCount = response.totalCount
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
