//
//  HrProfileViewModel.swift
//  WorkHive
//
//  Created by SAIL on 03/01/26.
//

//
//  EmpProfileViewModel.swift
//  WorkHive
//
//  Created by SAIL on 03/01/26.
//


import SwiftUI
import Combine


class HrProfileViewModel: ObservableObject {

  
    @AppStorage("hrId") var hrId: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userData: hrClass?

    private var cancellables = Set<AnyCancellable>()

    func getProfile() {

      

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getprofile,
            parameters: [
                "user_id": hrId   // ✅ REAL VALUE
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async { self.isLoading = false }

            if case let .failure(error) = completionResult {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { (response: hrprofile) in
            if response.success {
                self.userData = response.data
            } else {
                self.errorMessage = response.message
            }
        }
        .store(in: &cancellables)
    }
}



struct hrprofile: Codable {
    let success: Bool
    let message: String
    let data: hrClass
}

// MARK: - DataClass
struct hrClass: Codable {
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

