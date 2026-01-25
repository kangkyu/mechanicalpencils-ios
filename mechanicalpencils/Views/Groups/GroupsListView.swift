//
//  GroupsListView.swift
//  mechanicalpencils
//

import SwiftUI

struct GroupsListView: View {
    @StateObject private var viewModel = GroupsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.groups.isEmpty {
                    ProgressView("Loading...")
                } else if viewModel.groups.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Groups",
                        systemImage: "folder",
                        description: Text("Item groups will appear here")
                    )
                } else {
                    List {
                        ForEach(viewModel.groups) { group in
                            NavigationLink(value: group) {
                                GroupRowView(group: group)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Groups")
            .navigationDestination(for: ItemGroup.self) { group in
                GroupDetailView(groupId: group.id, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.fetchGroups()
            }
        }
        .task {
            await viewModel.fetchGroups()
        }
    }
}

struct GroupRowView: View {
    let group: ItemGroup

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.title)
                    .font(.headline)

                if let count = group.itemsCount {
                    Text("\(count) items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GroupsListView()
}
