//
//  LoginView.swift
//  mechanicalpencils
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color(red: 0.5, green: 0.3, blue: 0.6))

                    Text("Mechanical Pencils")
                        .font(.custom("OpenSans-Bold", size: 28))

                    Text("Track your collection")
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
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
                        await authViewModel.login(email: email, password: password)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .font(.custom("OpenSans-SemiBold", size: 17))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

                Button("Create Account") {
                    showRegister = true
                }
                .font(.custom("OpenSans-Regular", size: 15))

                Spacer()
            }
            .navigationTitle("")
            .sheet(isPresented: $showRegister) {
                RegisterView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}
