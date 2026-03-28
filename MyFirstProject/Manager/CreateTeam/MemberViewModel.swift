//
//  MemberViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  MemberPickerViewModel.swift
//  WorkHive
//
//  Created by SAIL on 05/01/26.
//

import Foundation
import Combine

class MemberPickerViewModel: ObservableObject {

    @Published var members: [TeamUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchMembers() {
        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getUsers,
            parameters:
            [
                "role": "Employee"
            ]
        )
        .sink { [weak self] completion in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] (response: MemberListResponse) in
            DispatchQueue.main.async {
                if response.success {
                    self?.members = response.data
                } else {
                    self?.errorMessage = "Unable to load members"
                }
            }
        }
        .store(in: &cancellables)
    }
}

struct MemberListResponse: Codable {
    let success: Bool
    let message: String?
    let data: [TeamUser]
}
