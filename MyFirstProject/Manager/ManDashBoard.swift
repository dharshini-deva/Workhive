//
//  ManDashboard.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct ManDashboardView: View {

    @Binding var path: NavigationPath

    // ✅ NEW VIEWMODEL FOR DASHBOARD
    @StateObject private var viewModel = ManDashboardViewModel()

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("Welcome back, Manager")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button {
                            path.append(AppRoute.mannotifi)
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

                        // ✅ ACTIVE PROJECT COUNT
                        ManStatCard(
                            icon: "folder.fill",
                            iconColor: .blue,
                            title: "Active Projects",
                            value: "\(viewModel.activeProjectsCount)"
                        )

                        // ✅ PENDING TASKS COUNT
                        ManStatCard(
                            icon: "clock.fill",
                            iconColor: .orange,
                            title: "Pending Tasks",
                            value: "\(viewModel.pendingTasksCount)" 
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Review Task
                    Text("Review Tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if viewModel.pendingTasks.isEmpty {
                        Text("No pending tasks to review")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 22) {
                            ForEach(viewModel.pendingTasks) { task in
                                ReviewTaskRow(
                                    title: task.task_name,
                                    subtitle: task.project_title,
                                    submittedDate: task.displayDate,
                                    onView: {
                                        // ✅ Navigation
                                        path.append(AppRoute.managerReviewTask(task))
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            // Floating Action Button
            HStack {
                Spacer()
                Button {
                    path.append(AppRoute.manreq)
                } label: {
                    Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color(hex: "#FDB913"))
                    .clipShape(Circle())
                    .shadow(radius: 6)
                }
                .padding()
            }
        }
        .background(Color.white)
        .onAppear {
            // ✅ FETCH DASHBOARD DATA
            viewModel.fetchDashboardData()
        }
    }
}

//
// MARK: - Stat Card
//
struct ManStatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(title)
                .foregroundColor(.gray)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

//
// MARK: - Review Task Row
//
//
// MARK: - Review Task Row
//
struct ReviewTaskRow: View {
    let title: String
    let subtitle: String // Added subtitle
    let submittedDate: String
    let onView: () -> Void // ✅ Callback for button action

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("Submitted: \(submittedDate)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: onView) { // ✅ Use callback
                Text("View")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#FDB913"))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
    }
}
