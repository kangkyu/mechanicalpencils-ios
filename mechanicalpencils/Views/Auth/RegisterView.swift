//
//  RegisterView.swift
//  mechanicalpencils
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Confirm Password", text: $passwordConfirmation)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.custom("OpenSans-Regular", size: 12))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        await authViewModel.register(
                            email: email,
                            password: password,
                            passwordConfirmation: passwordConfirmation
                        )
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .font(.custom("OpenSans-SemiBold", size: 17))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(!isFormValid || authViewModel.isLoading)

                Spacer()
            }
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create Account")
                        .font(.custom("OpenSans-Bold", size: 20))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password == passwordConfirmation && password.count >= 6
    }
}

#Preview {
    RegisterView(authViewModel: AuthViewModel())
}
