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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Groups")
                        .font(.custom("OpenSans-Bold", size: 20))
                }
            }
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
                    .font(.custom("OpenSans-SemiBold", size: 17))

                if let count = group.itemsCount {
                    Text("\(count) items")
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.custom("OpenSans-Regular", size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GroupsListView()
}
