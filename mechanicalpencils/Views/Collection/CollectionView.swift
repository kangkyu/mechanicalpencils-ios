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
            Group {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading...")
                } else if viewModel.items.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Items Yet",
                        systemImage: "tray",
                        description: Text("Items you add to your collection will appear here")
                    )
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            CollectionItemRow(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Collection (\(viewModel.totalCount))")
                        .font(.custom("OpenSans-Bold", size: 20))
                }
            }
            .refreshable {
                await viewModel.fetchCollection()
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
                    .font(.custom("OpenSans-SemiBold", size: 17))
                    .lineLimit(1)

                if let maker = item.maker {
                    Text(maker)
                        .font(.custom("OpenSans-Regular", size: 15))
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
