import Foundation
import SwiftUI
import Combine

@MainActor
class SendRequestViewModel: ObservableObject {

    @AppStorage("loggedInUserId") private var managerId: Int = 0

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    func sendRequest(
        title: String,
        requestType: String,
        details: String,
        value: String,
        projectId: Int = 0
    ) {

        guard managerId != 0 else {
            alertMessage = "Manager ID not found"
            showAlert = true
            return
        }

        isLoading = true
        alertMessage = ""

        guard let url = URL(string: ServiceApi.createManagerRequest) else {
            isLoading = false
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let body =
        "manager_id=\(managerId)" +
        "&project_id=\(projectId)" +
        "&title=\(title)" +
        "&request_type=\(requestType)" +
        "&details=\(details)" +
        "&value=\(value)"

        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data received"
                    self.showAlert = true
                }
                return
            }

            // Debug (optional)
            print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

            do {
                let response = try JSONDecoder().decode(
                    SendRequestResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    self.alertMessage = response.message
                    self.showAlert = true
                }

            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to parse response"
                    self.showAlert = true
                }
            }

        }.resume()
    }
}
struct SendRequestResponse: Decodable {
    let success: Bool
    let message: String
    let requestId: Int?
}
