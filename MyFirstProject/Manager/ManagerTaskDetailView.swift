import SwiftUI

struct ManagerTaskDetailView: View {
    @Binding var path: NavigationPath
    let task: ManagerPendingTask
    @AppStorage("managerId") private var managerId: String = ""

    @State private var comments: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                Button {
                    path.removeLast()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Text("Task Details")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                
                Spacer().frame(width: 24) // Balance the back button
            }
            .padding()
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Task Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        detailRow(title: "Task Name", value: task.task_name)
                        Divider()
                        detailRow(title: "Project", value: task.project_title)
                        Divider()
                        detailRow(title: "Employee", value: task.employee_name)
                        Divider()
                        detailRow(title: "Submitted On", value: task.displayDate)
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(task.description)
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Review Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manager Review")
                            .font(.headline)
                        
                        TextEditor(text: $comments)
                            .frame(height: 100)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .background(Color.gray.opacity(0.05))
                        
                        HStack(spacing: 16) {
                            // Reject Button
                            Button {
                                updateTaskStatus(status: "rejected")
                            } label: {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                } else {
                                    Text("Reject")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(isLoading)

                            // Approve Button
                            Button {
                                updateTaskStatus(status: "approved")
                            } label: {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Approve")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(isLoading)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
        }
        .background(Color(hex: "#F8F9FA"))
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        path.removeLast()
                    }
                }
            )
        }
    }

    // MARK: - Helper Views
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    // MARK: - Action
    private func updateTaskStatus(status: String) {
        guard let url = URL(string: ServiceApi.managerReviewTask) else { return }
        
        isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Encode parameters
        let bodyParameters = [
            "task_id": "\(task.id)",
            "status": status,
            "comment": comments,
            "manager_id": managerId
        ]
        
        let bodyString = bodyParameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let data = data else {
                    self.alertMessage = "No response from server"
                    self.showAlert = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool, success {
                        self.alertMessage = "Task \(status) successfully."
                    } else {
                        self.alertMessage = "Failed to update task status."
                    }
                } catch {
                    self.alertMessage = "Server error: \(error.localizedDescription)"
                }
                self.showAlert = true
            }
        }.resume()
    }
}
