//
//  ManagerPickerViewModel.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//
//
//  ManagerPickerViewModel.swift
//  WorkHive
//
//  Created by SAIL on 05/01/26.
//

import Foundation
import Combine

class ManagerPickerViewModel: ObservableObject {

    @Published var managers: [TeamUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchManagers() {
        isLoading = true
        errorMessage = nil

        APIClient.shared.postFormData(
            urlString: ServiceApi.getUsers,
            parameters:
            [
                "role": "Manager"
            ]
        )
        .sink { [weak self] completion in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] (response: ManagerListResponse) in
            DispatchQueue.main.async {
                if response.success {
                    self?.managers = response.data
                } else {
                    self?.errorMessage = "Failed to load managers"
                }
            }
        }
        .store(in: &cancellables)
    }
}


struct ManagerListResponse: Codable {
    let success: Bool
    let message: String?
    let data: [TeamUser]
}

