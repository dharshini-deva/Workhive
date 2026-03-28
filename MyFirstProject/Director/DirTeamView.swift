//
//  DirTeamView.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  DirectorTeamsViewModel.swift
//  WorkHive
//
//  Created by SAIL on 07/01/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class DirectorTeamsViewModel: ObservableObject {

    @AppStorage("DirectorId") private var directorId: String = ""

    @Published var teams: [DirectorTeam] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchTeams() {

        guard let id = Int(directorId), id > 0 else {
            errorMessage = "Director not logged in"
            return
        }

        let urlString = "\(ServiceApi.getDirectorTeams)?director_id=\(id)"
        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data else { return }

                do {
                    let response = try JSONDecoder().decode(
                        DirectorTeamsResponse.self,
                        from: data
                    )

                    if response.success {
                        self.teams = response.teams
                    }
                } catch {
                    print("❌ Decode error:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

struct DirectorTeamsResponse: Decodable {
    let success: Bool
    let teams: [DirectorTeam]
}

struct DirectorTeam: Identifiable, Decodable, Hashable {
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
