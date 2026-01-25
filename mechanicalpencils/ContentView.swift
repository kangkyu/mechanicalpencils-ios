//
//  ContentView.swift
//  mechanicalpencils
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView(authViewModel: authViewModel)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            ItemsListView()
                .tabItem {
                    Label("Browse", systemImage: "pencil.and.list.clipboard")
                }

            GroupsListView()
                .tabItem {
                    Label("Groups", systemImage: "folder")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "tray.full")
                }

            SettingsView(authViewModel: authViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
