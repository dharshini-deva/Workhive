//
//  CreateTeamViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//
import Foundation
import Combine

class CreateTeamViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var createdTeam: TeamData?

    private var cancellables = Set<AnyCancellable>()

    func createTeam(
        creatorId: Int,
        projectId: Int,
        teamName: String,
        managerIds: [Int],
        memberIds: [Int],
        completion: @escaping (Bool) -> Void
    ) {

        guard !teamName.isEmpty else {
            errorMessage = "Team name is required"
            completion(false)
            return
        }

            guard creatorId != 0 else {
                errorMessage = "Creator not found. Please login again."
                completion(false)
                return
            }

            guard projectId != 0 else {
                errorMessage = "Project not selected."
                completion(false)
                return
            }

            guard !teamName.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Team name is required"
                completion(false)
                return
            }
        isLoading = true
        errorMessage = nil

        let parameters: [String: String] = [
            "creator_id": "\(creatorId)",
            "project_id": "\(projectId)",
            "team_name": teamName,
            "managers": String(data: try! JSONEncoder().encode(managerIds), encoding: .utf8)!,
            "members": String(data: try! JSONEncoder().encode(memberIds), encoding: .utf8)!
        ]
        
        print("PARAMETERS:", parameters)

        APIClient.shared.postFormData(
            urlString: ServiceApi.createTeam,
            parameters: parameters
        )
        .sink { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if case let .failure(error) = result {
                self?.errorMessage = error.localizedDescription
                completion(false)
            }
        } receiveValue: { [weak self] (response: TeamResponse) in
            DispatchQueue.main.async {
                if response.success {
                    self?.successMessage = response.message
                    completion(true)
                } else {
                    self?.errorMessage = response.message
                    completion(false)
                }
            }
        }
        .store(in: &cancellables)
    }
}


struct TeamResponse: Codable {
    let success: Bool
    let message: String
    let data: TeamData?
}

// MARK: - DataClass
struct TeamData: Codable {
    let teamId: Int
    let projectId: Int
    let name: String
    let createdBy: Int
    let createdAt: String
    let managers: [TeamUser]
    let members: [TeamUser]

    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case projectId = "project_id"
        case name
        case createdBy = "created_by"
        case createdAt = "created_at"
        case managers
        case members
    }
}
struct TeamUser: Codable, Identifiable {
    let id: Int
    let fullName: String
    let email: String
    let teamRole: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case teamRole = "team_role"
        case profileImage = "profile_image"
    }
}

