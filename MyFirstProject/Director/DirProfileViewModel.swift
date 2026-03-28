//
//  DirProfileViewModel.swift
//  WorkHive
//
//  Created by SAIL on 03/01/26.
//

//
//  ManagerProfleViewModel.swift
//  WorkHive
//
//  Created by SAIL on 03/01/26.
//
import SwiftUI
import Combine


class DirProfileViewModel: ObservableObject {


    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userData: DirClass?
    
    @AppStorage("DirectorId") var DirectorId: String = ""
    private var cancellables = Set<AnyCancellable>()

    func getProfile() {

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getprofile,
            parameters: [
                "user_id": DirectorId   // ✅ REAL VALUE
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async { self.isLoading = false }

            if case let .failure(error) = completionResult {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { (response: dirprofile) in
            if response.success {
                self.userData = response.data
            } else {
                self.errorMessage = response.message
            }
        }
        .store(in: &cancellables)
    }
}



struct dirprofile: Codable {
    let success: Bool
    let message: String
    let data: DirClass
}

// MARK: - DataClass
struct DirClass: Codable {
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

