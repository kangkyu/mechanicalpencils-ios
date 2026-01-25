//
//  UserProfileView.swift
//  mechanicalpencils
//

import SwiftUI

struct UserProfileView: View {
    let userId: Int
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if let user = viewModel.user {
                List {
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.email)
                                    .font(.custom("OpenSans-SemiBold", size: 17))
                                Text("\(viewModel.totalCount) items")
                                    .font(.custom("OpenSans-Regular", size: 15))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    if !viewModel.items.isEmpty {
                        Section("Collection") {
                            ForEach(viewModel.items) { item in
                                UserProfileItemRow(item: item)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.custom("OpenSans-Bold", size: 20))
            }
        }
        .task {
            await viewModel.fetchUserProfile(id: userId)
        }
    }
}

struct UserProfileItemRow: View {
    let item: UserProfileItem

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

            if item.hasProof, let proofUrl = item.proofUrl, let url = URL(string: proofUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .cornerRadius(4)
                    default:
                        Image(systemName: "camera.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
