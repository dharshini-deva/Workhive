import Foundation
import SwiftUI
import Combine

class ManDashboardViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var activeProjectsCount: Int = 0
    @Published var pendingTasksCount: Int = 0
    @Published var pendingTasks: [ManagerPendingTask] = [] // Renamed to avoid conflicts
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Stored Properties
    @AppStorage("managerId") var managerId: String = ""

    // MARK: - Fetch Dashboard Data
    func fetchDashboardData() {
        guard let id = Int(managerId), id > 0 else {
            errorMessage = "Manager ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let dispatchGroup = DispatchGroup()
        
        // 1. Fetch Active Projects Count
        dispatchGroup.enter()
        fetchProjects(managerId: id) {
            dispatchGroup.leave()
        }
        
        // 2. Fetch Pending Tasks
        dispatchGroup.enter()
        fetchPendingTasks(managerId: id) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }

    // MARK: - Fetch Projects (for Active Count)
    private func fetchProjects(managerId: Int, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(ServiceApi.getManagerProjects)?manager_id=\(managerId)") else {
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { completion() }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(ManProjectResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if response.success {
                        // Filter active projects
                        self.activeProjectsCount = response.projects.filter {
                            $0.status.lowercased() == "active"
                        }.count
                    }
                }
            } catch {
                print("Error fetching projects: \(error)")
            }
        }.resume()
    }

    // MARK: - Fetch Pending Tasks
    private func fetchPendingTasks(managerId: Int, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(ServiceApi.managerGetPendingTasks)?manager_id=\(managerId)") else {
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { completion() }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(ManagerPendingTaskResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.success {
                        self.pendingTasks = response.tasks
                        self.pendingTasksCount = response.count
                    }
                }
            } catch {
                print("Error fetching pending tasks: \(error)")
            }
        }.resume()
    }
}

// MARK: - Models

struct ManagerPendingTaskResponse: Codable {
    let success: Bool
    let tasks: [ManagerPendingTask]
    let count: Int
}

struct ManagerPendingTask: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let task_name: String
    let description: String
    let task_status: String
    let created_at: String
    let project_title: String
    let employee_name: String
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: ManagerPendingTask, rhs: ManagerPendingTask) -> Bool {
        return lhs.id == rhs.id
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: created_at) {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
        return created_at
    }
}
