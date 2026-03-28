//
//  DirDashboard.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI


struct DirectorDashboardView: View {

    @Binding var path: NavigationPath
    @StateObject private var viewModel = DirectorRequestsViewModel()
    @StateObject private var projectViewModel = DirectorProjectsViewModel()


    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("Welcome back")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button {
                            path.append(AppRoute.dirNotifi)
                        } label: {
                            Image(systemName: "bell")
                                .font(.title2)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    // MARK: - Stats Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Active Projects",
                            value: "\(projectViewModel.activeProjectsCount)")
                        StatCard(
                            title: "Pending Approvals",
                            value: "\(viewModel.requests.count)"
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Approval Requests
                    Text("Approval Requests")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.requests.isEmpty {
                        Text("No pending requests")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.requests) { req in
                                ApprovalCard(
                                    requestId: req.id,
                                    title: req.title,
                                    project: req.projectId == 0
                                        ? "General Request"
                                        : "Project ID \(req.projectId)",
                                    requestedBy: req.managerName,
                                    value: req.value,
                                    urgent: req.requestType.lowercased() == "budget",
                                    onApprove: { id in
                                        viewModel.processRequest(
                                            requestId: id,
                                            action: "approve"
                                        )
                                    },
                                    onReject: { id in
                                        viewModel.processRequest(
                                            requestId: id,
                                            action: "reject"
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .onAppear {
                
                viewModel.fetchDirectorRequests(status: "pending")
                projectViewModel.fetchProjects() 
            }

        }
        .background(Color.white)
    }
}


//# MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.gray)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
// MARK: - Approval Card
struct ApprovalCard: View {

    let requestId: Int
    let title: String
    let project: String
    let requestedBy: String
    let value: String
    let urgent: Bool

    let onApprove: (Int) -> Void
    let onReject: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(project)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                Spacer()

                if urgent {
                    Text("Urgent")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(10)
                }
            }

            HStack {
                Text("Requested by \(requestedBy)")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Spacer()

                Text(value)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }

            HStack(spacing: 12) {

                Button {
                    onApprove(requestId)
                } label: {
                    Text("Approve")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button {
                    onReject(requestId)
                } label: {
                    Text("Reject")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}



struct TabItem: View {
    let icon: String
    let title: String
    var active: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(active ? .orange : .gray)

            Text(title)
                .font(.caption)
                .foregroundColor(active ? .orange : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

