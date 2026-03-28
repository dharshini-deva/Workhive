//
//  AdminDashViewModel.swift
//  WorkHive
//
//  Created by SAIL on 09/01/26.
//
import SwiftUI
import Foundation
import Combine

 class AdminUserViewModel: ObservableObject {
    
    @Published var users: [AdminUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch users
    func fetchUsers() {

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: ServiceApi.getAdmin) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            DispatchQueue.main.async { self.isLoading = false }

            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data else { return }

            do {
                let decoded = try JSONDecoder().decode([AdminUser].self, from: data)
                DispatchQueue.main.async {
                    self.users = decoded.filter { $0.role.lowercased() != "admin" } // ✅ Filter out admin
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load profiles"
                }
            }
        }.resume()
    }

    // MARK: - Delete user
    func deleteUser(userId: String) {

        guard let url = URL(string: ServiceApi.deleteAdminUser) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "user_id": userId
        ])

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data else { return }

            do {
                let response = try JSONDecoder().decode(DeleteResponse.self, from: data)

                DispatchQueue.main.async {
                    if response.success {
                        self.users.removeAll { $0.id == userId }   // ✅ correct place
                    } else {
                        self.errorMessage = response.message
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Delete failed"
                }
            }
        }.resume()
    }

    // MARK: - Roles
    var roles: [String] {
        Array(Set(users.map { $0.role })).sorted()
    }
}


struct AdminUser: Identifiable, Decodable, Hashable {
    let id: String
    let full_name: String
    let role: String
    let phone: String
    let email: String
}


struct DeleteResponse: Decodable {
    let success: Bool
    let message: String
}
