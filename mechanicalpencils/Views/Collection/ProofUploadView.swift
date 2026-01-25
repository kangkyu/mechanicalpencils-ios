//
//  ProofUploadView.swift
//  mechanicalpencils
//

import SwiftUI
import PhotosUI

struct ProofUploadView: View {
    let item: CollectionItem
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isUploading = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Item info
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                        default:
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundStyle(.gray)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        if let maker = item.maker {
                            Text(maker)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Current proof
                if let proofUrl = item.proofUrl, let url = URL(string: proofUrl) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Proof")
                            .font(.headline)

                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                            default:
                                ProgressView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                // Selected image preview
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Proof")
                            .font(.headline)

                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    if selectedImageData != nil, let ownershipId = item.ownershipId {
                        Button {
                            Task {
                                isUploading = true
                                if let imageData = selectedImageData {
                                    let success = await viewModel.uploadProof(
                                        ownershipId: ownershipId,
                                        imageData: imageData
                                    )
                                    if success {
                                        dismiss()
                                    }
                                }
                                isUploading = false
                            }
                        } label: {
                            if isUploading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Label("Upload Proof", systemImage: "arrow.up.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isUploading)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Proof Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
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
    }
}
