import Foundation
import SwiftUI
import Combine

struct ReminderItem: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let start_date: String
    let end_date: String? // ✅ Optional end_date
    let start_time: String
    let end_time: String
    let day_id: Int
    let repeat_everyday: Int
}


final class ReminderViewModel: ObservableObject {

    // MARK: - State
    @Published var reminders: [ReminderItem] = []
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false

    // MARK: - CREATE REMINDER
    func createReminder(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date, // ✅ Added endDate parameter
        startTime: Date,
        endTime: Date,
        selectedDayId: Int?,
        repeatEveryday: Bool,
        path: Binding<NavigationPath>
    ) {

        guard !title.isEmpty else {
            showError("Please enter title")
            return
        }

        guard let userId = Int(UserDefaults.standard.string(forKey: "employeeId") ?? "") else {
            showError("Invalid user")
            return
        }

        guard endTime > startTime else {
            showError("End time must be after start time")
            return
        }

        guard let url = URL(string: ServiceApi.createReminder) else {
            showError("Invalid server URL")
            return
        }

        isLoading = true

        let body: [String: Any] = [
            "user_id": userId,
            "title": title,
            "description": description,
            "start_date": startDate.toDateString(),
            "end_date": endDate.toDateString(),  // ✅ Pass End Date
            "start_time": startTime.toTimeString(),
            "end_time": endTime.toTimeString(),
            "day_id": selectedDayId ?? 0,
            "repeat_everyday": repeatEveryday ? 1 : 0
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }

                guard let data = data,
                      let response = try? JSONDecoder().decode(APIResponse.self, from: data)
                else {
                    self.showError("Invalid server response")
                    return
                }

                if response.success {
                    self.alertMessage = response.message
                    self.isSuccess = true
                    self.showAlert = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        path.wrappedValue.removeLast()
                    }
                } else {
                    self.showError(response.message)
                }
            }
        }.resume()
    }

    // MARK: - FETCH REMINDERS
    func fetchReminders() {

        guard let userId = Int(UserDefaults.standard.string(forKey: "employeeId") ?? "") else {
            return
        }

        guard let url = URL(
            string: "\(ServiceApi.getReminders)?user_id=\(userId)"
        ) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(ReminderListResponse.self, from: data)

                DispatchQueue.main.async {
                    if response.success {
                        self.reminders = response.reminders
                    }
                }

            } catch {
                print("Reminder decode error:", error)
            }
        }.resume()
    }

    // MARK: - Helpers
    private func showError(_ message: String) {
        alertMessage = message
        isSuccess = false
        showAlert = true
    }
}

// MARK: - API Models
struct APIResponse: Codable {
    let success: Bool
    let message: String
}

struct ReminderListResponse: Codable {
    let success: Bool
    let reminders: [ReminderItem]
}

// MARK: - Date Helpers
extension Date {

    func toDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }

    func toTimeString() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: self)
    }
}
