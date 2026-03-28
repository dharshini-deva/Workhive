import SwiftUI

struct HrLeaveView: View {

    @Binding var path: NavigationPath
    

    @StateObject private var viewModel = HrLeaveViewModel()
    @State private var selectedTab: LeaveTab = .all

    var filteredLeaves: [HrLeave] {
        switch selectedTab {
        case .all:
            return viewModel.leaves
        case .pending:
            return viewModel.leaves.filter {
                $0.status.lowercased() == "pending"
            }
        case .approved:
            return viewModel.leaves.filter {
                $0.status.lowercased() == "approved"
            }
        case .rejected:
            return viewModel.leaves.filter {
                $0.status.lowercased() == "rejected"
            }
        }
    }


    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Leave Management")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            // MARK: - Tabs
            HStack {
                tabButton(.all)
                tabButton(.pending)
                tabButton(.approved)
                tabButton(.rejected)
            }
            .padding(.horizontal)

            // MARK: - Leave List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    ForEach(filteredLeaves, id: \.id) { leave in
                        leaveCard(leave)
                    }

                    if filteredLeaves.isEmpty {
                        Text("No leave requests")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchLeaves()
        }
    }

    // MARK: - Leave Card (INLINE)
    private func leaveCard(_ leave: HrLeave) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: - Status Badge
            HStack {
                Spacer()

                Text(leave.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(leave.status))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }

            // MARK: - Leave Details
            Text("Employee: \(leave.employeeName)")
                .font(.subheadline)
                .fontWeight(.semibold)

            
            Text("Type: \(leave.leaveType)")
                .font(.subheadline)

            Text("Dates: \(leave.startDate) - \(leave.endDate)")
                .font(.subheadline)

            Text("Duration: \(leave.duration)")
                .font(.subheadline)

            Text("Reason")
                .fontWeight(.semibold)

            Text(leave.reason)
                .foregroundColor(.gray)

            // MARK: - Action Buttons (ONLY for Pending)
            if leave.status.lowercased() == "pending" {
                HStack(spacing: 12) {

                    // Reject Button
                    Button {
                        viewModel.processLeave(
                            leaveId: leave.id,
                            action: "reject"
                        )

                    } label: {
                        Text("Reject")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red)
                            )
                    }

                    // Approve Button
                    Button {
                        viewModel.processLeave(
                            leaveId: leave.id,
                            
                            action: "accept"
                        )
                    } label: {
                        Text("Approve")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#FDB913"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.3))
        )
    }


    // MARK: - Helpers
    private func tabButton(_ tab: LeaveTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(tab.rawValue)
                .fontWeight(.semibold)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(selectedTab == tab ? Color.yellow : Color.clear)
                .foregroundColor(selectedTab == tab ? .white : .gray)
                .cornerRadius(10)
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "approved":
            return .green
        case "rejected":
            return .red
        default:
            return .yellow
        }
    }
}

// MARK: - Tabs Enum
enum LeaveTab: String {
    case all = "All"
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}
