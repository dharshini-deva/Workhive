//
//  EmptasKView.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

import SwiftUI

struct MyTasksView: View {

    @StateObject private var viewModel = EmpTaskViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                headerView

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.top, 30)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }

                tasksList

                Spacer(minLength: 30)
            }
        }
        .background(Color.white)
        .onAppear {
            if viewModel.projects.isEmpty {
                viewModel.fetchEmployeeProjects()
            }
        }
    }
}

// MARK: - Subviews
private extension MyTasksView {

    var headerView: some View {
        HStack {
            Text("My Tasks")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Text("See all")
                .font(.subheadline)
                .foregroundColor(.yellow)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    var tasksList: some View {
        VStack(spacing: 14) {

            if viewModel.projects.isEmpty && !viewModel.isLoading {
                Text("No tasks assigned yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            }

            ForEach(viewModel.projects) { project in
                EmployeeTaskCard(
                    title: project.title,
                    deadline: viewModel.formattedDate(project.deadline),
                    review: viewModel.formattedDate(project.reviewOn),
                    status: project.status,
                    progress: viewModel.progressValue(for: project)
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Employee Task Card (Manager-style)
struct EmployeeTaskCard: View {

    let title: String
    let deadline: String
    let review: String
    let status: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top Row
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(status)
                    .font(.caption)
                    .foregroundColor(
                        status.lowercased() == "completed" ? .green : .yellow
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        (status.lowercased() == "completed"
                         ? Color.green
                         : Color.yellow).opacity(0.15)
                    )
                    .cornerRadius(12)
            }

            // Progress
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
                    .tint(
                        status.lowercased() == "completed"
                        ? .green
                        : .yellow
                    )
            }

            // Dates
            VStack(alignment: .leading, spacing: 4) {
                Text("Deadline: \(deadline)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Review: \(review)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    MyTasksView()
}
