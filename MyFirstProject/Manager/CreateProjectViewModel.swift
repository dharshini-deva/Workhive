import Foundation
import Combine

class CreateProjectViewModel: ObservableObject {

    @Published var title = ""
    @Published var description = ""
    @Published var deadline = "2026-03-30"
    @Published var reviewOn = "2026-03-01"
    @Published var budget = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    @Published var projectData: Project?

    private var cancellables = Set<AnyCancellable>()

    func createProject(
        managerId: String,
        completion: @escaping (Bool, String) -> Void
    ) {

        guard !managerId.isEmpty else {
            completion(false, "Manager not logged in")
            return
        }

        guard !title.isEmpty, !description.isEmpty else {
            completion(false, "Title and Description are required")
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.createproject,
            parameters: [
                "manager_id": managerId,
                "title": title,
                "description": description,
                "deadline": deadline,
                "review_on": reviewOn,
                "budget": budget
            ]
        )
        .sink { result in
            DispatchQueue.main.async { self.isLoading = false }

            if case let .failure(error) = result {
                completion(false, error.localizedDescription)
            }
        } receiveValue: { (response: CreateProjectResponse) in
            if response.success {
                self.projectData = response.project
                self.isSuccess = true
                completion(true, response.message)
            } else {
                completion(false, response.message)
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: - CreateProjectResp
struct CreateProjectResponse: Decodable {
    let success: Bool
    let message: String
    let project: Project?
}

// MARK: - Project Model
struct Project: Codable {
    let projectId: Int
    let managerId: Int
    let title: String
    let description: String
    let deadline: String
    let reviewOn: String
    let budget: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case managerId = "manager_id"
        case title
        case description
        case deadline
        case reviewOn = "review_on"
        case budget
        case status
        case createdAt = "created_at"
    }
}
