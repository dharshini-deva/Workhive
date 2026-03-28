import SwiftUI
import Foundation
import Combine

// MARK: - ViewModel
class EmpTaskViewModel: ObservableObject {
    
    // Single source of truth
    @AppStorage("employeeId") private var employeeId: String = ""

    @Published var projects: [EmployeeProject] = []
    
    // ✅ NEW Published property for daily tasks
    @Published var dailyTasks: [DailyTask] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Fetch Daily Tasks
    func fetchDailyTasks() {
        guard !employeeId.isEmpty else { return }
        
        let urlString = "\(ServiceApi.getDailyTasks)?employee_id=\(employeeId)&date=\(Date().toDateString())"
        print("Fetching tasks from: \(urlString)")
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                // decoder.keyDecodingStrategy = .convertFromSnakeCase // Check PHP output
                // PHP output creates {"tasks": [{"id":..., "task_name":...}]}
                // It likely returns raw keys unless my PHP used snake_case -> camelCase conversion?
                // My PHP uses raw keys from DB. I'll use coding keys or match them.
                
                let response = try decoder.decode(DailyTaskResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.success {
                        self.dailyTasks = response.tasks
                    }
                }
            } catch {
                print("Daily Task Decode Error: \(error)")
            }
        }.resume()
    }


    // MARK: - Fetch Employee Projects
    func fetchEmployeeProjects() {

        guard !employeeId.isEmpty else {
            errorMessage = "Employee ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(
            string: "\(ServiceApi.getEmployeeProjects)?employee_id=\(employeeId)"
        ) else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let response = try decoder.decode(
                    EmployeeProjectsResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    if response.success {
                        self.projects = response.data
                    } else {
                        self.errorMessage = response.message
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse response"
                }
            }
        }.resume()
    }

    // MARK: - Progress Logic (same style as Manager)
    func progressValue(for project: EmployeeProject) -> Double {
        project.status.lowercased() == "completed" ? 1.0 : 0.6
    }

    // MARK: - Date Formatting
    func formattedDate(_ dateString: String) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - API Models

struct EmployeeProjectsResponse: Codable {
    let success: Bool
    let message: String
    let data: [EmployeeProject]
    let totalCount: Int
}

struct EmployeeProject: Codable, Identifiable {
    let id: String
    let title: String
    let deadline: String
    let reviewOn: String
    let status: String
}

// ✅ NEW Models
struct DailyTaskResponse: Codable {
    let success: Bool
    let tasks: [DailyTask]
}

struct DailyTask: Codable, Identifiable {
    let id: Int
    let task_name: String
    let status: String
    let description: String
    let created_at: String
    let project_title: String
    
    // Computed property for UI
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: created_at) {
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: date)
        }
        return ""
    }
}

