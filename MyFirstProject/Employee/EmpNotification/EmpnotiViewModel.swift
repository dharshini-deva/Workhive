//
//  EmpnotiViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  EmpNotificationModel.swift
//  WorkHive
//
//  Created by SAIL on 02/01/26.
//
import Foundation
import SwiftUI
import Combine

final class EmpNotificationModel: ObservableObject {

    @Published var notifications: [EmpNotificationItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchNotifications(userId: String) {

        print("📡 fetchNotifications called with userId:", userId)
        
        guard !userId.isEmpty, userId != "0" else {
            print("Invalid userId")
            return
        }

        isLoading = true

        let urlString =
            "\(ServiceApi.getEmployeeNotifications)?user_id=\(userId)"

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoded =
                    try JSONDecoder().decode(EmpNotificationResponse.self, from: data)

                DispatchQueue.main.async {
                    self.notifications = decoded.notifications
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode notifications"
                    print(error)
                }
            }
        }.resume()
    }
}


    // MARK: - Approve / Reject leave
//    func processLeave(leaveId: String, hrId: String, action: String) {
//
//        guard let url = URL(string: ServiceApi.getEmployeeNotifications) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let body = "leave_id=\(leaveId)&hr_id=\(hrId)&action=\(action)"
//        request.httpBody = body.data(using: .utf8)
//
//        URLSession.shared.dataTask(with: request) { _, _, _ in
//            DispatchQueue.main.async {
//                self.fetchLeaves()   // refresh list after action
//            }
//        }.resume()
//    }
//}



struct EmpNotificationResponse: Codable {
    let success: Bool
    let notifications: [EmpNotificationItem]
}

struct EmpNotificationItem: Codable, Identifiable {
    let id: Int
    let title: String
    let message: String
    let isRead: Int
    let createdAt: String
    let profileImage: String? // ✅ Added profileImage

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case isRead = "is_read"
        case createdAt = "created_at"
        case profileImage = "profile_image" // ✅ Map from JSON
    }
}


