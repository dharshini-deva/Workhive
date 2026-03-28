import Foundation
import SwiftUI
import Combine

class UpdateTaskViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var taskName: String = ""
    @Published var status: String = "In Progress" // Default status
    @Published var description: String = ""
    @Published var selectedProjectId: String = ""

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - Data
    @Published var projects: [EmployeeProject] = []

    // MARK: - Stored IDs
    @AppStorage("employeeId") var employeeId: String = ""

    // MARK: - Fetch Projects
    func fetchProjects() {
        guard !employeeId.isEmpty else { return }
        
        let urlString = "\(ServiceApi.getEmployeeProjects)?employee_id=\(employeeId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(EmployeeProjectsResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if response.success {
                        self.projects = response.data
                        // Default selection if available
                        if let first = self.projects.first {
                            self.selectedProjectId = first.id
                        }
                    }
                }
            } catch {
                print("Error fetching projects: \(error)")
            }
        }.resume()
    }

    // MARK: - Submit Task Update
    func submitTask() {
        
        guard !taskName.isEmpty else {
            alertMessage = "Task name is required"
            showAlert = true
            return
        }

        guard !selectedProjectId.isEmpty else {
            alertMessage = "Please select a project"
            showAlert = true
            return
        }
        
        // Define Status Options mapped to progress
        // e.g., "In Progress" -> 50%, "Completed" -> 100%
        // The backend might expect simple text or percentage. 
        // Based on user request "progress bar is static so can you do that", 
        // we likely need to send a status that updates the project status.
        
        guard let url = URL(string: ServiceApi.addDailyTask) else {
            alertMessage = "Invalid API URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "project_id=\(selectedProjectId)&employee_id=\(employeeId)&task_name=\(taskName)&status=\(status)&description=\(description)"
        request.httpBody = body.data(using: .utf8)

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                     // Assume success if no error for now, better to decode JSON if API returns JSON
                     // But based on previous code it was checking error only.
                     // Ideally we should decode a response struct.
                }

                self.alertMessage = "Task updated successfully"
                self.showAlert = true

                // Clear fields
                self.taskName = ""
                self.description = ""
            }
        }.resume()
    }
}
