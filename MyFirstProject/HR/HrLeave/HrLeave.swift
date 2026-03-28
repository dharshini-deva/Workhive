//
//  HrLeave.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

import SwiftUI
import Foundation
import Combine

class HrLeaveViewModel: ObservableObject {
    
    @AppStorage("hrId") private var hrId: String = ""

    @Published var leaves: [HrLeave] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch all leave requests
    func fetchLeaves() {
        isLoading = true
        errorMessage = nil

        // ✅ MUST be API that returns ALL leaves
        guard let url = URL(string: ServiceApi.getPendingLeaves) else {
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
                let decoded = try JSONDecoder().decode(
                    HrLeaveResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    if decoded.success {
                        self.leaves = decoded.data
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode leave data"
                }
            }
        }.resume()
    }


    // MARK: - Approve / Reject leave
    func processLeave(leaveId: String, action: String) {

        guard !hrId.isEmpty else { return }

        guard let url = URL(string: ServiceApi.processLeave) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "leave_id=\(leaveId)&hr_id=\(hrId)&action=\(action)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.fetchLeaves()
            }
        }.resume()
    }

}




struct HrLeaveResponse: Codable {
    let success: Bool
    let data: [HrLeave]
}


struct HrLeave: Codable {
    let id, userID, employeeName, leaveType: String
    let startDate, endDate, duration, reason: String
    let status, createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case employeeName = "employee_name"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case duration, reason, status
        case createdAt = "created_at"
    }
}
