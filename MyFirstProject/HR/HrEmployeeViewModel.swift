// HrEmployeeViewModel.swift

import Foundation
import SwiftUI
import Combine

class HrEmployeeViewModel: ObservableObject {

    @Published var employees: [HrUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchEmployees() {

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: ServiceApi.getProfiles) else {
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
                let decoded = try JSONDecoder().decode(ProfileListResponse.self, from: data)
                DispatchQueue.main.async {
                    self.employees = decoded.data
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load profiles"
                }
            }
        }.resume()
    }
}
