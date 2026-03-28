//
//  ManNotificationViewModel.swift
//  WorkHive
//
//  Created by SAIL on 07/01/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class ManNotificationViewModel: ObservableObject {

    @AppStorage("managerId") private var managerId: String = ""

    @Published var notifications: [EmpNotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var managerIntId: Int {
        Int(managerId) ?? 0
    }

    func fetchNotifications() {

        guard managerIntId > 0 else { return }

        let urlString =
        "\(ServiceApi.getEmployeeNotifications)?user_id=\(managerIntId)"

        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, _, error in
            Task { @MainActor in
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data else { return }

                do {
                    let decoded =
                        try JSONDecoder().decode(EmpNotificationResponse.self, from: data)

                    self.notifications = decoded.notifications
                } catch {
                    self.errorMessage = "Failed to decode notifications"
                }
            }
        }.resume()
    }
}
