//
//  ItemsListView.swift
//  mechanicalpencils
//

import SwiftUI

struct ItemsListView: View {
    @StateObject private var viewModel = ItemsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink(value: item) {
                        ItemRowView(item: item)
                    }
                }

                if viewModel.hasMorePages && !viewModel.items.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadNextPage()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Pencils")
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(itemId: item.id, itemsViewModel: viewModel)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search pencils")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.search()
                }
            }
            .refreshable {
                await viewModel.fetchItems(refresh: true)
            }
            .overlay {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading...")
                } else if viewModel.items.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Pencils",
                        systemImage: "pencil.slash",
                        description: Text("No mechanical pencils found")
                    )
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .task {
            await viewModel.fetchItems(refresh: true)
        }
    }
}

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                case .failure:
                    Image(systemName: "pencil")
                        .font(.title2)
                        .foregroundStyle(.gray)
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                if let maker = item.maker {
                    Text(maker)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let modelNumber = item.modelNumber {
                    Text(modelNumber)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if item.owned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ItemsListView()
}
