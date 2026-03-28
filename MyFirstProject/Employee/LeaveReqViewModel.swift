//
//  EmpLeaveModel.swift
//  WorkHive
//
//  Created by SAIL on 31/12/25.
//


import Foundation
import Combine

class EmpLeaveViewModel: ObservableObject {

    // MARK: - Input
    @Published var leaveType: String = "Medical Leave"
    @Published var reason: String = ""

    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSuccess: Bool = false

    // MARK: - Data
    @Published var leaveData: Leave?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Submit Leave
    func submitLeave(
        userId: String,
        completion: @escaping (_ success: Bool, _ message: String) -> Void
    ) {

        guard !reason.isEmpty else {
            let msg = "Reason is required"
            errorMessage = msg
            completion(false, msg)
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.createLeave,   // ⬅️ add in ApiList
            parameters: [
                "user_id": userId,
                "leave_type": leaveType,
                "start_date": "2025-01-10",
                "end_date": "2025-01-12",
                "duration": "3 days",
                "reason": reason
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if case let .failure(error) = completionResult {
                let msg = error.localizedDescription
                self.errorMessage = msg
                completion(false, msg)
            }
        } receiveValue: { (response: LeaveResponse) in
            if response.success {
                self.leaveData = response.leave
                self.isSuccess = true
                completion(true, response.message)
            } else {
                self.errorMessage = response.message
                completion(false, response.message)
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: - LeaveResponse
struct LeaveResponse: Decodable {
    let success: Bool
    let message: String
    let leave: Leave?
}

// MARK: - Leave Model
struct Leave: Codable {
    let id: Int
    let userId:  Int
    let leaveType: String
    let startDate: String
    let endDate: String
    let duration: String
    let reason: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case duration
        case reason
        case status
        case createdAt = "created_at"
    }
}
