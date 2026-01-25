//
//  CollectionView.swift
//  mechanicalpencils
//

import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @State private var selectedItem: CollectionItem?

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.itemGroups.isEmpty {
                    Section("Groups") {
                        ForEach(viewModel.itemGroups) { group in
                            HStack {
                                Text(group.title)
                                Spacer()
                                if let count = group.itemsCount {
                                    Text("\(count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Items (\(viewModel.totalCount))") {
                    ForEach(viewModel.items) { item in
                        CollectionItemRow(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
            }
            .navigationTitle("My Collection")
            .refreshable {
                await viewModel.fetchCollection()
            }
            .overlay {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading...")
                } else if viewModel.items.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Items Yet",
                        systemImage: "tray",
                        description: Text("Items you add to your collection will appear here")
                    )
                }
            }
            .sheet(item: $selectedItem) { item in
                ProofUploadView(item: item, viewModel: viewModel)
            }
        }
        .task {
            await viewModel.fetchCollection()
        }
    }
}

struct CollectionItemRow: View {
    let item: CollectionItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                case .failure:
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundStyle(.gray)
                        .frame(width: 50, height: 50)
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)

                if let maker = item.maker {
                    Text(maker)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if item.hasProof {
                Image(systemName: "camera.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "camera")
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CollectionView()
}
