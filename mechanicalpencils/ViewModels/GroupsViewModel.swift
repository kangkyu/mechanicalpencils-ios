//
//  GroupsViewModel.swift
//  mechanicalpencils
//

import Foundation
import Combine

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [ItemGroup] = []
    @Published var selectedGroup: ItemGroup?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func fetchGroups() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchItemGroups()
            groups = response.itemGroups
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchGroupDetail(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchItemGroup(id: id)
            selectedGroup = response.itemGroup
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
