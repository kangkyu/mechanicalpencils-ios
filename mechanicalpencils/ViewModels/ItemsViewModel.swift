//
//  ItemsViewModel.swift
//  mechanicalpencils
//

import Foundation
import Combine

@MainActor
class ItemsViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var currentItem: ItemDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    @Published var currentPage = 1
    @Published var totalPages = 1

    var hasMorePages: Bool { currentPage < totalPages }

    private let apiClient = APIClient.shared

    func fetchItems(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchItems(
                page: currentPage,
                search: searchText.isEmpty ? nil : searchText
            )

            if refresh {
                items = response.items
            } else {
                items.append(contentsOf: response.items)
            }

            totalPages = response.pagination.totalPages
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard hasMorePages, !isLoading else { return }
        currentPage += 1
        await fetchItems()
    }

    func search() async {
        currentPage = 1
        items = []
        await fetchItems(refresh: true)
    }

    func fetchItem(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchItem(id: id)
            currentItem = response.item
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func ownItem(id: Int) async {
        do {
            let response = try await apiClient.ownItem(id: id)
            currentItem = response.item
            // Update the item in the list
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = Item(
                    id: response.item.id,
                    title: response.item.title,
                    maker: response.item.maker?.title,
                    modelNumber: response.item.modelNumber,
                    imageUrl: response.item.thumbnailUrl,
                    owned: response.item.owned
                )
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unownItem(id: Int) async {
        do {
            let response = try await apiClient.unownItem(id: id)
            currentItem = response.item
            // Update the item in the list
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = Item(
                    id: response.item.id,
                    title: response.item.title,
                    maker: response.item.maker?.title,
                    modelNumber: response.item.modelNumber,
                    imageUrl: response.item.thumbnailUrl,
                    owned: response.item.owned
                )
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
