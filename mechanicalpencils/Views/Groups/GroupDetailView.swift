//
//  GroupDetailView.swift
//  mechanicalpencils
//

import SwiftUI

struct GroupDetailView: View {
    let groupId: Int
    @ObservedObject var viewModel: GroupsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let group = viewModel.selectedGroup {
                List {
                    if let items = group.items, !items.isEmpty {
                        ForEach(items) { item in
                            GroupItemRow(item: item)
                        }
                    } else {
                        ContentUnavailableView(
                            "No Items",
                            systemImage: "pencil.slash",
                            description: Text("This group has no items")
                        )
                    }
                }
                .listStyle(.plain)
                .navigationTitle(group.title)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchGroupDetail(id: groupId)
        }
    }
}

struct GroupItemRow: View {
    let item: Item

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

            if item.owned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
