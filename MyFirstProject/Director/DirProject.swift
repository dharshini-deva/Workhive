//
//  DirProject.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct ProjectsView: View {

    @StateObject private var viewModel = DirectorProjectsViewModel()

    // MARK: - Filters
    @State private var selectedFilter: String = "All Projects"
    private let filters = ["All Projects", "Active", "Completed"]

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        Text("Projects")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()
                    }
                    .padding(.horizontal)

                    // MARK: - Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Text(filter)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedFilter == filter
                                        ? Color.yellow
                                        : Color(.systemGray6)
                                    )
                                    .foregroundColor(
                                        selectedFilter == filter
                                        ? .white
                                        : .gray
                                    )
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        selectedFilter = filter
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Project Cards
                    VStack(spacing: 16) {

                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        }

                        ForEach(filteredProjects) { project in
                            ProjectCard(
                                title: project.title,
                                owner: project.ownerName,
                                progress: progressValue(project.status),
                                status: project.status,
                                statusColor: statusColor(project.status),
                                date: project.deadline ?? "-"
                            )
                        }

                        if !viewModel.isLoading && viewModel.projects.isEmpty {
                            Text("No projects found")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .background(Color.white)
        .onAppear {
            viewModel.fetchProjects()
        }
    }

    // MARK: - Filtered Projects
    
    private func normalizedStatus(_ status: String) -> String {
        status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var filteredProjects: [DirectorProject] {
        switch selectedFilter {
        case "Active":
            return viewModel.projects.filter {
                normalizedStatus($0.status) == "active"
            }
        case "Completed":
            return viewModel.projects.filter {
                normalizedStatus($0.status) == "completed"
            }
        default:
            return viewModel.projects
        }
    }


    // MARK: - Helpers
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active":
            return .yellow
        case "completed":
            return .green
        
        default:
            return .gray
        }
    }

    private func progressValue(_ status: String) -> Double {
        switch status.lowercased() {
        case "completed":
            return 1.0
        case "active":
            return 0.6
        case "on hold":
            return 0.3
        default:
            return 0.0
        }
    }
}

//
// MARK: - Project Card
//
struct ProjectCard: View {

    let title: String
    let owner: String
    let progress: Double
    let status: String
    let statusColor: Color
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text(status.capitalized)
                    .font(.caption)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .foregroundColor(.gray)
                }

                ProgressView(value: progress)
                    .tint(Color(hex: "#FDB913"))
            }

            HStack {
                Text(owner)
                    .foregroundColor(.gray)

                Spacer()

                Text(date)
                    .foregroundColor(.gray)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ProjectsView()
}
