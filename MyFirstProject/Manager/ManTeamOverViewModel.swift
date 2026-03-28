//
//  ManTeamOverViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ManTeamsOverViewModel: ObservableObject {

    @AppStorage("managerId") var managerId: String = ""

    @Published var teams: [TeamOverview] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchTeams() {

        guard let id = Int(managerId), id > 0 else {
            errorMessage = "Director not logged in"
            return
        }

        let urlString =
        "\(ServiceApi.getManagerTeams)?manager_id=\(managerId)"

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
                        ManTeamsOverviewResponse.self,
                        from: data
                    )

                    if response.success {
                        self.teams = response.teams
                    } else {
                        self.errorMessage = "Failed to load teams"
                    }

                } catch {
                    print("❌ Decode error:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

struct ManTeamsOverviewResponse: Decodable {
    let success: Bool
    let teams: [TeamOverview]
}

struct TeamOverview: Identifiable, Decodable,Hashable {
    let id: Int
    let teamName: String
    let projectTitle: String
    let projectStatus: String
    let managerName: String
    let teamSize: Int

    enum CodingKeys: String, CodingKey {
        case id = "team_id"
        case teamName = "team_name"
        case projectTitle = "project_title"
        case projectStatus = "project_status"
        case managerName = "manager_name"
        case teamSize = "team_size"
    }
}
