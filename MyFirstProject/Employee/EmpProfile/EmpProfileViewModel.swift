//
//  EmpProfileViewModel.swift
//  WorkHive
//
//  Created by SAIL on 03/01/26.
//


import SwiftUI
import Combine


class EmpProfileViewModel: ObservableObject {

  
    @AppStorage("employeeId") var employeeId: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userData: empClass?

    private var cancellables = Set<AnyCancellable>()

    func getProfile() {


        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getprofile,
            parameters: [
                "user_id": employeeId   // ✅ REAL VALUE
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async { self.isLoading = false }

            if case let .failure(error) = completionResult {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { (response: empprofile) in
            if response.success {
                self.userData = response.data
            } else {
                self.errorMessage = response.message
            }
        }
        .store(in: &cancellables)
    }
}



struct empprofile: Codable {
    let success: Bool
    let message: String
    let data: empClass
}

// MARK: - DataClass
struct empClass: Codable {
    let id: String
    let role, fullName, email, phone: String
    let profileImage, dob: String

    enum CodingKeys: String, CodingKey {
        case id, role
        case fullName = "full_name"
        case email, phone
        case profileImage = "profile_image"
        case dob
    }
}

