import Foundation
import SwiftUI
import Combine

@MainActor
class DirectorRequestsViewModel: ObservableObject {

    // ✅ SAME FORMAT AS LOGIN / HR / EMPLOYEE
    @AppStorage("DirectorId") private var directorId: String = ""

    @Published var requests: [DirectorRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // ✅ Safe conversion
    private var directorIntId: Int {
        Int(directorId) ?? 0
    }

    // MARK: - Fetch Requests
    func fetchDirectorRequests(status: String = "pending") {

        guard directorIntId > 0 else {
            errorMessage = "Director not logged in"
            return
        }

        let urlString =
        "\(ServiceApi.getDirectorRequests)?status=\(status)"

        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, _, error in
            Task { @MainActor in
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data else { return }

                do {
                    let decoded = try JSONDecoder()
                        .decode(DirectorRequestResponse.self, from: data)

                    self.requests = decoded.requests
                } catch {
                    self.errorMessage = "Failed to decode requests"
                }
            }
        }.resume()
    }

    // MARK: - Approve / Reject
    func processRequest(requestId: Int, action: String) {

        guard directorIntId > 0 else { return }

        guard let url = URL(string: ServiceApi.processManagerRequest) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let body =
        "director_id=\(directorIntId)&request_id=\(requestId)&action=\(action)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            Task { @MainActor in
                self.fetchDirectorRequests()
            }
        }.resume()
    }
}

struct DirectorRequestResponse: Decodable {
    let success: Bool
    let requests: [DirectorRequest]
}

struct DirectorRequest: Identifiable, Decodable {
    let id: Int
    let managerId: Int
    let managerName: String
    let projectId: Int
    let title: String
    let requestType: String
    let details: String
    let value: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case managerId = "manager_id"
        case managerName = "manager_name"
        case projectId = "project_id"
        case title, requestType = "request_type"
        case details, value, status
        case createdAt = "created_at"
    }
}
