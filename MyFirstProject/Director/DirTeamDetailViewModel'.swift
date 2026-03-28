//
//  DirTeamDetailViewModel'.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  DirectorTeamDetailViewModel.swift
//  WorkHive
//
//  Created by SAIL on 07/01/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class DirectorTeamDetailViewModel: ObservableObject {

    @Published var teamName: String = ""
    @Published var projectTitle: String = ""
    @Published var progress: Double = 0.0

    @Published var managers: [TeamPerson] = []
    @Published var members: [TeamPerson] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchTeamDetails(teamId: Int) {

        let urlString =
        "\(ServiceApi.getDirectorTeamDetail)?team_id=\(teamId)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data else {
                    self.errorMessage = "No data"
                    return
                }

                do {
                    let response = try JSONDecoder().decode(
                        DirectorTeamDetailResponse.self,
                        from: data
                    )

                    guard response.success else {
                        self.errorMessage = "API failed"
                        return
                    }

                    self.teamName = response.teamName
                    self.projectTitle = response.projectTitle
                    self.managers = response.managers
                    self.members = response.members

                    // Simple progress logic (same as your other screens)
                    self.progress =
                        response.projectStatus.lowercased() == "completed"
                        ? 1.0
                        : 0.6

                } catch {
                    print("❌ Decode error:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}


struct DirectorTeamDetailResponse: Decodable {
    let success: Bool
    let teamName: String
    let projectTitle: String
    let projectStatus: String
    let managers: [TeamPerson]
    let members: [TeamPerson]

    enum CodingKeys: String, CodingKey {
        case success
        case teamName = "team_name"
        case projectTitle = "project_title"
        case projectStatus = "project_status"
        case managers
        case members
    }
}

struct TeamPerson: Identifiable, Decodable {
    let id: Int
    let name: String
    let role: String
    let image: String?

    var imageURL: URL? {
        guard let image else { return nil }
        return URL(string: ServiceApi.BaseUrl + image)
    }
}

