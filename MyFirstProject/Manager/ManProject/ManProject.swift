import SwiftUI

struct ManProjectsView: View {

    @Binding var path: NavigationPath
    @StateObject private var viewModel = ManProjectsViewModel()

    @State private var selectedFilter = "All Projects"
    private let filters = ["All Projects", "Active", "Completed"]

    var filteredProjects: [ManProject] {
        switch selectedFilter {
        case "Active":
            return viewModel.projects.filter {
                $0.status.lowercased() == "active"
            }
        case "Completed":
            return viewModel.projects.filter {
                $0.status.lowercased() == "completed"
            }
        default:
            return viewModel.projects
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Header
                HStack {
                    Text("Projects")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        path.append(AppRoute.Mancp)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Filters (single line)
                HStack(spacing: 12) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        selectedFilter == filter
                                        ? Color.yellow
                                        : Color(.systemGray6)
                                    )
                            )
                            .foregroundColor(
                                selectedFilter == filter
                                ? .white
                                : .gray
                            )
                            .onTapGesture {
                                selectedFilter = filter
                            }
                    }
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView("Loading projects...")
                        .padding(.top, 40)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                VStack(spacing: 14) {
                    ForEach(filteredProjects) { project in

                        let progress: Double = {
                            switch project.status.lowercased() {
                            case "completed": return 1.0
                            case "active": return 0.6
                            default: return 0.0
                            }
                        }()

                        ManProjectCard(
                            title: project.title,
                            status: project.status.capitalized,
                            statusColor: statusColor(project.status),
                            progress: progress,
                            owner: "Teams: \(project.teamCount)",
                            date: project.deadline
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .onAppear {
            viewModel.fetchManagerProjects()
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .yellow
        case "completed": return .green
        default: return .gray
        }
    }
}



struct ManProjectCard: View {

    let title: String
    let status: String
    let statusColor: Color
    let progress: Double
    let owner: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(status)
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
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ProgressView(value: progress)
                    .tint(Color(hex: "#FDB913"))
            }

            HStack {
                Text(owner)
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }
}
