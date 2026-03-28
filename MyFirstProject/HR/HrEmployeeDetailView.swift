// HrEmployeeDetailViewModel.swift

import Foundation
import Combine

class HrEmployeeDetailViewModel: ObservableObject {

    @Published var employee: HrUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchEmployeeDetail(employeeId: String) {

        guard !employeeId.isEmpty else {
            errorMessage = "Employee ID missing"
            return
        }

        isLoading = true
        errorMessage = nil

        let urlString = "\(ServiceApi.getProfiles)?employee_id=\(employeeId)"

        guard let url = URL(string: urlString) else {
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
                let decoded = try JSONDecoder().decode(ProfileSingleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.employee = decoded.data
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load profile"
                }
            }
        }.resume()
    }
}
