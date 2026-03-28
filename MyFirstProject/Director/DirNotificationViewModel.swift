//
//  DirNotificationViewModel.swift
//  WorkHive
//
//  Created by ANTIGRAVITY on 11/02/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DirNotificationViewModel: ObservableObject {

    @AppStorage("directorId") private var directorId: String = ""

    @Published var notifications: [EmpNotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var directorIntId: Int {
        Int(directorId) ?? 0
    }

    func fetchNotifications() {

        guard directorIntId > 0 else { return }

        let urlString = "\(ServiceApi.getEmployeeNotifications)?user_id=\(directorIntId)"

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
                    let decoded = try JSONDecoder().decode(EmpNotificationResponse.self, from: data)
                    self.notifications = decoded.notifications
                } catch {
                    self.errorMessage = "Failed to decode notifications"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
