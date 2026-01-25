//
//  ItemDetailView.swift
//  mechanicalpencils
//

import SwiftUI

struct ItemDetailView: View {
    let itemId: Int
    @ObservedObject var itemsViewModel: ItemsViewModel
    @State private var isToggling = false

    var body: some View {
        ScrollView {
            if let item = itemsViewModel.currentItem {
                VStack(spacing: 20) {
                    // Image
                    AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 250)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                        case .failure:
                            Image(systemName: "pencil")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                                .frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Title and Maker
                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.custom("OpenSans-Bold", size: 28))
                            .multilineTextAlignment(.center)

                        if let maker = item.maker {
                            Text(maker.title ?? "")
                                .font(.custom("OpenSans-SemiBold", size: 20))
                                .foregroundStyle(.secondary)
                        }

                        if let modelNumber = item.modelNumber {
                            Text("Model: \(modelNumber)")
                                .font(.custom("OpenSans-Regular", size: 15))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal)

                    // Ownership Button
                    Button {
                        Task {
                            isToggling = true
                            if item.owned {
                                await itemsViewModel.unownItem(id: item.id)
                            } else {
                                await itemsViewModel.ownItem(id: item.id)
                            }
                            isToggling = false
                        }
                    } label: {
                        HStack {
                            if isToggling {
                                ProgressView()
                            } else {
                                Image(systemName: item.owned ? "checkmark.circle.fill" : "plus.circle")
                                Text(item.owned ? "In Collection" : "Add to Collection")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(item.owned ? .green : .blue)
                    .padding(.horizontal)
                    .disabled(isToggling)

                    // Description
                    if let description = item.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("OpenSans-SemiBold", size: 17))
                            Text(description)
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.custom("OpenSans-SemiBold", size: 17))

                        if let tipRetractable = item.tipRetractable {
                            FeatureRow(label: "Tip Retractable", value: tipRetractable)
                        }

                        if let eraserAttached = item.eraserAttached {
                            FeatureRow(label: "Eraser Attached", value: eraserAttached)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // External Links
                    if item.jetpensUrl != nil || item.blickUrl != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Where to Buy")
                                .font(.custom("OpenSans-SemiBold", size: 17))

                            if let jetpensUrl = item.jetpensUrl, let url = URL(string: jetpensUrl) {
                                Link(destination: url) {
                                    HStack {
                                        Text("JetPens")
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                    }
                                }
                            }

                            if let blickUrl = item.blickUrl, let url = URL(string: blickUrl) {
                                Link(destination: url) {
                                    HStack {
                                        Text("Blick Art Materials")
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    // Proof Photos from Owners
                    if let proofs = item.proofs, !proofs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Proof Photos")
                                    .font(.custom("OpenSans-SemiBold", size: 17))
                                Spacer()
                                if let count = item.ownersCount {
                                    Text("\(count) owners")
                                        .font(.custom("OpenSans-Regular", size: 15))
                                        .foregroundStyle(.secondary)
                                }
                            }

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(proofs) { proof in
                                    NavigationLink(destination: UserProfileView(userId: proof.userId)) {
                                        ProofPhotoCard(proof: proof)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    } else if let ownersCount = item.ownersCount, ownersCount > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Owners")
                                .font(.custom("OpenSans-SemiBold", size: 17))
                            Text("\(ownersCount) people own this pencil")
                                .font(.custom("OpenSans-Regular", size: 15))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
            } else if itemsViewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await itemsViewModel.fetchItem(id: itemId)
        }
    }
}

struct FeatureRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.custom("OpenSans-Regular", size: 15))
        }
    }
}

struct ProofPhotoCard: View {
    let proof: ItemProof

    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: proof.proofUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(8)

            Text(proof.userEmail.components(separatedBy: "@").first ?? "User")
                .font(.custom("OpenSans-Regular", size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
