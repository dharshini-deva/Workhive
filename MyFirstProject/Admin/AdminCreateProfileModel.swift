//
//  LoginViewModel.swift
//  WorkHive
//
//  Created by SAIL on 26/12/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI


class AdminCreateViewModel: ObservableObject {
    
   
    
    @Published  var fullName: String = ""
    @Published  var selectedRole: String = ""
    @Published  var dob: Date = Date()
    @Published  var email: String = ""
    @Published  var phone: String = ""
    @Published  var password: String = ""
    @Published  var selectedRoles: UserRole? = nil
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var userData: User?
    
    

    private var cancellables = Set<AnyCancellable>()

    func createUser(
        adminId: Int,
        role: String,
        fullName: String,
        email: String,
        password: String,
        phone: String,
        dob: Date,
        profileImage: Image?,          // ✅ SwiftUI Image
        resumeURL: URL?,               // ✅ PDF URL
        completion: @escaping (_ success: Bool, _ message: String) -> Void
    ) {

        // MARK: - Validation
        guard adminId != 0,
              !role.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {

            let msg = "Required fields missing"
            errorMessage = msg
            completion(false, msg)
            return
        }

        isLoading = true
        errorMessage = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: dob)

        // MARK: - Parameters
        let parameters: [String: String] = [
            "admin_id": "\(adminId)",
            "role": role,
            "full_name": fullName,
            "email": email,
            "password": password,
            "phone": phone,
            "dob": dobString
        ]

        // MARK: - Files
        var files: [MultipartFile] = []

        // ✅ Convert SwiftUI Image → UIImage → Data
        if let image = profileImage,
           let uiImage = image.asUIImage(),
           let imageData = uiImage.jpegData(compressionQuality: 0.8) {

            files.append(
                MultipartFile(
                    key: "profile_image",
                    fileName: "profile.jpg",
                    data: imageData,
                    mimeType: "image/jpeg"
                )
            )
        }

        // ✅ Resume PDF (URL → Data)
        if let resumeURL = resumeURL,
           let resumeData = try? Data(contentsOf: resumeURL) {

            files.append(
                MultipartFile(
                    key: "resume",
                    fileName: resumeURL.lastPathComponent,
                    data: resumeData,
                    mimeType: "application/pdf"
                )
            )
        }

        // MARK: - API Call
        APIClient.shared.postMultipartFormData(
            urlString: ServiceApi.createAccount,
            parameters: parameters,
            files: files
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

        } receiveValue: { (response: CommonResponse) in
            if response.success {
                completion(true, response.message)
            } else {
                self.errorMessage = response.message
                completion(false, response.message)
            }
        }
        .store(in: &cancellables)
    }



}


struct CommonResponse:Decodable {
    let success: Bool
    let message:String
   
}

struct MultipartFile {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
}

import SwiftUI

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let size = CGSize(width: 300, height: 300)
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
