import Foundation
import SwiftUI
import Combine

@MainActor
class DirectorProjectsViewModel: ObservableObject {

    // Must match LoginPage key exactly
    @AppStorage("DirectorId") private var directorId: String = ""

    @Published var projects: [DirectorProject] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var activeProjectsCount: Int {
            projects.filter {
                $0.status.trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased() == "active"
            }.count
        }

    func fetchProjects() {

        guard let directorIntId = Int(directorId), directorIntId > 0 else {
            self.errorMessage = "Director not logged in"
            return
        }

        let urlString = "\(ServiceApi.getDirectorProjects)?director_id=\(directorIntId)"

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    // ❌ DO NOT use convertFromSnakeCase here

                    let response = try decoder.decode(
                        DirectorProjectResponse.self,
                        from: data
                    )

                    if response.success {
                        self.projects = response.projects
                        print("✅ Director projects fetched:", response.projects.count)
                    } else {
                        self.errorMessage = "API returned failure"
                    }

                } catch {
                    print("❌ Decode error:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}
struct DirectorProjectResponse: Decodable {
    let success: Bool
    let projects: [DirectorProject]
}
struct DirectorProject: Identifiable, Decodable {

    let id: Int
    let title: String
    let status: String
    let deadline: String?
    let createdAt: String
    let teamsCount: Int
    let ownerName: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case status
        case deadline
        case createdAt = "created_at"
        case teamsCount = "teams_count"
        case ownerName = "owner_name"
    }
}
