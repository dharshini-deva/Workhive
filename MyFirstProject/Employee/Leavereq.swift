import SwiftUI

struct EmpLeaveRequestView: View {

    @Binding var path: NavigationPath

    // MARK: - Backend mapped fields
    @State private var leaveType: String = "Casual Leave"
    @State private var startDate: String = "2025-01-10"
    @State private var endDate: String = "2025-01-12"
    @State private var duration: String = "3 days"
    @State private var reason: String = ""
    @State private var status: String = "pending"

    @AppStorage("employeeId") private var employeeId: String = ""


    @StateObject private var viewModel = EmpLeaveViewModel()

    @State private var showAlert: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {

                // MARK: - Title
                Text("Leave Request")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // MARK: - Leave Type
                readOnlyField(title: "Leave Type", value: leaveType)

                // MARK: - Start Date
                readOnlyField(title: "Start Date", value: startDate)

                // MARK: - End Date
                readOnlyField(title: "End Date", value: endDate)

                // MARK: - Duration
                readOnlyField(title: "Duration", value: duration)

                // MARK: - Reason (Editable)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Reason")
                        .font(.headline)

                    TextEditor(text: $reason)
                        .frame(height: 120)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4))
                        )
                }

                // MARK: - Status (Read-only)
                HStack {
                    Text("Status")
                        .font(.headline)

                    Spacer()

                    Text(status.capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // MARK: - Submit Button
                Button {
                    viewModel.reason = reason
                    viewModel.leaveType = leaveType

                    viewModel.submitLeave(userId: employeeId) { success, message in
                        showAlert = true
                        if success {
                            status = "pending"   // system state
                        }
                    }
                } label: {
                    Text(viewModel.isLoading ? "Submitting..." : "Submit Request")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FDB913"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isLoading || reason.isEmpty)

                Spacer(minLength: 30)
            }
            .padding()
            .alert("Leave Request", isPresented: $showAlert) {
                Button("OK") {
                    if viewModel.isSuccess {
                        path.removeLast()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "Leave request submitted successfully")
            }
        }
        .background(Color.white)
    }

    // MARK: - Status Color
    private var statusColor: Color {
        switch status.lowercased() {
        case "approved":
            return .green
        case "rejected":
            return .red
        default:
            return .yellow // pending
        }
    }
}

//
// MARK: - Reusable Read-Only Field
//
private extension EmpLeaveRequestView {

    func readOnlyField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}
