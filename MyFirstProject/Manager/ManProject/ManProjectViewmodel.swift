import Foundation
import SwiftUI
import Combine

@MainActor
class ManProjectsViewModel: ObservableObject {

    // ✅ Store managerId as String (same as Director)
    @AppStorage("managerId") private var managerId: String = ""

    @Published var projects: [ManProject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var activeProjectsCount: Int {
        projects.filter { $0.status.lowercased() == "active" }.count
    }


    func fetchManagerProjects() {

        // ✅ Convert String → Int safely
        guard let managerIdInt = Int(managerId), managerIdInt > 0 else {
            errorMessage = "Manager ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(
            string: "\(ServiceApi.getManagerProjects)?manager_id=\(managerIdInt)"
        ) else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            // Debug
            print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let response = try decoder.decode(
                    ManProjectResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    if response.success {
                        self.projects = response.projects
                    } else {
                        self.errorMessage = "Failed to load projects"
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse response"
                }
            }

        }.resume()
    }
}

struct ManProjectResponse: Decodable {
    let success: Bool
    let managerId: Int
    let projects: [ManProject]
}

struct ManProject: Identifiable, Decodable {

    let id: Int
    let managerId: Int
    let title: String
    let description: String
    let deadline: String
    let reviewOn: String
    let budget: String
    let status: String
    let createdAt: String
    let updatedAt: String
    let teamCount: Int
    let memberCount: Int
}
