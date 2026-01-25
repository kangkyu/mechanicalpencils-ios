//
//  AuthViewModel.swift
//  mechanicalpencils
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared
    private let keychain = KeychainManager.shared

    init() {
        isAuthenticated = keychain.hasToken
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(email: String, password: String, passwordConfirmation: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.register(
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
            currentUser = response.user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() async {
        isLoading = true

        do {
            try await apiClient.logout()
        } catch {
            // Even if logout fails on server, clear local state
        }

        currentUser = nil
        isAuthenticated = false
        isLoading = false
    }

    func checkAuthStatus() {
        isAuthenticated = keychain.hasToken
    }
}
