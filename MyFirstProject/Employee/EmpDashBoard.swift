//
//  EmpDashboardView.swift
//  WorkHive
//
//  FINAL – Dashboard with TODAY’S REMINDERS (COUNT ONLY)
//

import SwiftUI

struct EmpDashboardView: View {

    @Binding var path: NavigationPath

    @StateObject private var taskViewModel = EmpTaskViewModel()
    @StateObject private var reminderViewModel = ReminderViewModel()

    @AppStorage("employeeId") private var employeeId: String = ""

    // MARK: - TODAY’S REMINDERS ONLY
    private var todaysReminders: [ReminderItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        return reminderViewModel.reminders.filter { reminder in
            if reminder.repeat_everyday == 1 {
                return true
            }
            // Logic: Start Date <= Today <= End Date
            // Simple string comparison works for yyyy-MM-dd format
            let start = reminder.start_date
            let end = reminder.end_date ?? reminder.start_date
            
            return todayStr >= start && todayStr <= end
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {

                    headerView
                    summaryCards
                    todaysTasksSection
                    todaysReportSection
                }
                .padding(.bottom, 80) // only for scroll content
            }
            .background(Color.white)
            .onAppear {
                taskViewModel.fetchEmployeeProjects()
                taskViewModel.fetchDailyTasks() // ✅ Fetch Updates
                reminderViewModel.fetchReminders()
            }

            chatbotButton
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 1)
        }
    }


}

// MARK: - HEADER
private extension EmpDashboardView {

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 14) {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Button {
                            path.append(AppRoute.empleave)
                        } label: {
                            Image(systemName: "briefcase")
                                .foregroundColor(Color(hex: "#FDB913"))
                        }
                    )

                Button {
                    path.append(AppRoute.empnotifi)
                } label: {
                    Image(systemName: "bell")
                        .font(.title2)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - SUMMARY CARDS
private extension EmpDashboardView {

    var summaryCards: some View {
        HStack(spacing: 14) {

            // TASKS COUNT
            EmpSummaryCard(
                icon: "checkmark.circle",
                iconColor: .yellow,
                title: "Projects",
                value: "\(taskViewModel.projects.count)",
                subtitle: "Assigned"
            )

            // HOURS → REMINDER COUNT (AS REQUESTED)
            EmpSummaryCard(
                icon: "clock",
                iconColor: .pink,
                title: "Schedule",
                value: "\(todaysReminders.count)",
                subtitle: "Logged today"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - TODAY’S TASKS LIST (REMINDERS)
private extension EmpDashboardView {

    var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Today's Schedule")
                .fontWeight(.bold)

            if todaysReminders.isEmpty {
                Text("No reminders for today")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                ForEach(todaysReminders) { reminder in
                    TaskRow(
                        title: reminder.title,
                        time: formatTime(reminder.start_time),
                        dotColor: .yellow
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - TODAY’S REPORT
private extension EmpDashboardView {

    var todaysReportSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Today's Report")
                .font(.headline)

            VStack(spacing: 16) {
                HStack {
                    Text("Report Status :")
                        .font(.subheadline)

                    Text(taskViewModel.dailyTasks.isEmpty ? "Not Updated" : "Updated")
                        .font(.subheadline)
                        .foregroundColor(taskViewModel.dailyTasks.isEmpty ? .red : .green)

                    Spacer()
                }

                Button {
                    path.append(AppRoute.updatetask)
                } label: {
                    Text(taskViewModel.dailyTasks.isEmpty ? "Update Task" : "Edit Update")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FDB913"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - TIME FORMATTER
private extension EmpDashboardView {

    func formatTime(_ time: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "HH:mm:ss"

        let output = DateFormatter()
        output.dateFormat = "hh:mm a"

        if let date = input.date(from: time) {
            return output.string(from: date)
        }
        return time
    }
}

private extension EmpDashboardView {

    var chatbotButton: some View {
        Button {
            path.append(AppRoute.empchatbot) // 👉 your chatbot screen
        } label: {
            Image(systemName: "message.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color(hex: "#FDB913"))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16) // 👈 keeps it ABOVE tab bar
    }
}


// MARK: - REUSABLE COMPONENTS
struct EmpSummaryCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: icon)
                .foregroundColor(iconColor)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
    }
}

struct TaskRow: View {
    let title: String
    let time: String
    let dotColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

//            Image(systemName: "chevron.right")
//                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25))
        )
    }
}
