//
//  LoginViewModel.swift
//  WorkHive
//
//  Created by SAIL on 26/12/25.
//

import Foundation
import Combine


class LoginViewModel: ObservableObject {

    @Published  var selectedRole: String = ""
    @Published  var email: String = ""
    @Published  var password: String = "12345"
    @Published  var selectedRoles: UserRole? = nil
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var userData: User?
    
    

    private var cancellables = Set<AnyCancellable>()

    func login(completion: @escaping (_ success: Bool, _ message: String) -> Void) {

        guard !email.isEmpty, !password.isEmpty else {
            let msg = "Email and password required"
            errorMessage = msg
            completion(false, msg)
            return
        }

        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.Login,
            parameters: [
                "email": email,
                "password": password,
                "role":selectedRole
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
        } receiveValue: { (response: LoginResponse) in
            if response.success {
                self.userData = response.data
                completion(true, response.message)   // ✅ SUCCESS + MESSAGE
            } else {
                self.errorMessage = response.message
                completion(false, response.message)  // ✅ FAILURE + MESSAGE
            }
        }
        .store(in: &cancellables)
    }

}

struct LoginResponse: Decodable {
    let success: Bool
    let message: String
    let data: User
}

// MARK: - DataClass
struct User: Codable {
    let id, role, fullName, email: String
    
    enum CodingKeys: String, CodingKey {
        case id, role
        case fullName = "full_name"
        case email
    }
}

