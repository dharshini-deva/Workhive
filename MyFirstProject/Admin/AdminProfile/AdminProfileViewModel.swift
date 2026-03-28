//
//  AdminProfileViewModel.swift
//  WorkHive
//
//  Created by SAIL on 23/01/26.
//

import SwiftUI
import Combine


class adminProfileViewModel: ObservableObject {


    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userData: adminClass?
    
    @AppStorage("AdminId") var AdminId: String = ""
    private var cancellables = Set<AnyCancellable>()

    func getProfile() {

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getprofile,
            parameters: [
                "user_id": AdminId
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async { self.isLoading = false }

            if case let .failure(error) = completionResult {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { (response: adminprofile) in
            if response.success {
                self.userData = response.data
            } else {
                self.errorMessage = response.message
            }
        }
        .store(in: &cancellables)
    }
    
    func updateProfile(fullName: String, email: String, phone: String, dob: Date, completion: @escaping (Bool, String) -> Void) {
        
        isLoading = true
        errorMessage = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = formatter.string(from: dob)
        
        // Using admin_update_user.php which we made generic for users
        APIClient.shared.postFormData(
            urlString: ServiceApi.updateAdminUser,
            parameters: [
                "user_id": AdminId,
                "full_name": fullName,
                "email": email,
                "phone": phone,
                "role": userData?.role ?? "Admin",
                "dob": dobString
            ]
        )
        .sink { completionResult in
            DispatchQueue.main.async { self.isLoading = false }
            
            if case let .failure(error) = completionResult {
                completion(false, error.localizedDescription)
            }
        } receiveValue: { (response: CommonResponse) in
            if response.success {
                self.getProfile() // Refresh data
                completion(true, response.message)
            } else {
                completion(false, response.message)
            }
        }
        .store(in: &cancellables)
    }
}



struct adminprofile: Codable {
    let success: Bool
    let message: String
    let data: adminClass
}

// Reuse or define CommonResponse locally if needed
// struct CommonResponse: Decodable {
//    let success: Bool
//    let message: String
// }

// MARK: - DataClass
struct adminClass: Codable {
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

