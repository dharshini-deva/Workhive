//
//  DirTeamViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  DirTeams.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

 struct DirTeamsView: View {
    
    @StateObject private var viewModel = DirectorTeamsViewModel()
    @State private var selectedTeam: DirectorTeam?   // 👈

    var body: some View {

      
            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 18) {

                    Text("Teams")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

                    if viewModel.isLoading {
                        ProgressView().padding(.top, 40)
                    }

                    VStack(spacing: 14) {
                        ForEach(viewModel.teams) { team in
                            TeamCard(
                                teamName: team.teamName,
                                progress: team.projectStatus.lowercased() == "completed" ? 1.0 : 0.6,
                                progressColor: team.projectStatus.lowercased() == "completed" ? .green : .yellow,
                                teamSize: "\(team.teamSize)",
                                manager: team.managerName,
                                rightTitle: "Project",
                                rightValue: team.projectTitle,
                                highlightColor: .primary,
                                onViewTap: {
                                    selectedTeam = team   // 👈 set team
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationDestination(item: $selectedTeam) { team in
                TeamDetailView(teamId: team.id)   // 👈 pass ID
            }
            .onAppear {
                viewModel.fetchTeams()
            }
        
    }
}


//
// MARK: - Team Card
//
struct TeamCard: View {

    let teamName: String
    let progress: Double?
    let progressColor: Color

    let teamSize: String
    let manager: String

    let rightTitle: String
    let rightValue: String
    let highlightColor: Color
    
    let onViewTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top Row
            HStack {
                Text(teamName)
                    .font(.headline)

                Spacer()

                Text("View")
                    .font(.caption)
                    .foregroundColor((Color(hex: "#FDB913")))
                    .onTapGesture {
                                            onViewTap()   // 👈 trigger navigation
                                        }
            }

            // Progress (Optional)
            if let progress {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ProgressView(value: progress)
                        .tint(progressColor)
                }
            }

            // Bottom Details
            HStack {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Team Size")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(teamSize)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Managed By")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(manager)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(rightTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(rightValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(highlightColor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}

