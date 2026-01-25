//
//  SettingsView.swift
//  mechanicalpencils
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.currentUser {
                    Section("Account") {
                        HStack {
                            Text("Email")
                                .font(.custom("OpenSans-Regular", size: 17))
                            Spacer()
                            Text(user.email)
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundStyle(.secondary)
                        }

                        if user.admin {
                            HStack {
                                Text("Role")
                                    .font(.custom("OpenSans-Regular", size: 17))
                                Spacer()
                                Text("Admin")
                                    .font(.custom("OpenSans-Regular", size: 17))
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                            .font(.custom("OpenSans-Regular", size: 17))
                        Spacer()
                        Text("1.0.0")
                            .font(.custom("OpenSans-Regular", size: 17))
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("Source Code")
                                .font(.custom("OpenSans-Regular", size: 17))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.logout()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if authViewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Out")
                                    .font(.custom("OpenSans-SemiBold", size: 17))
                            }
                            Spacer()
                        }
                    }
                    .disabled(authViewModel.isLoading)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(authViewModel: AuthViewModel())
}
