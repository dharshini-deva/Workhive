

import SwiftUI

struct SendRequestView: View {

    @State private var requestTitle = ""
    @State private var requestSubject = ""
    @State private var selectedRequestType = "select"
    @State private var count = ""

    @Binding var path: NavigationPath
    @StateObject private var viewModel = SendRequestViewModel()

    private let requestTypes = [
        "Budget",
        "Time extend",
        "Add member"
    ]

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    ReqInputField(
                        title: "request Title",
                        placeholder: "Enter Request Title",
                        text: $requestTitle
                    )

                    ReqInputField(
                        title: "request subject",
                        placeholder: "Enter Subject",
                        text: $requestSubject
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("request Type")
                            .font(.headline)

                        Menu {
                            ForEach(requestTypes, id: \.self) { type in
                                Button(type) {
                                    selectedRequestType = type
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRequestType)
                                    .foregroundColor(
                                        selectedRequestType == "select" ? .gray : .black
                                    )
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(12)
                        }
                    }

                    ReqInputField(
                        title: "count",
                        placeholder: "",
                        text: $count
                    )
                }
                .padding()
            }

            Button(action: sendRequest) {
                Text("Send request")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FDB913"))
                    .cornerRadius(14)
            }
            .padding()
        }
        .alert("Status", isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.alertMessage == "Request created" {
                    path.removeLast()
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    // MARK: - Helper
    private func sendRequest() {

        let backendType: String
        switch selectedRequestType {
        case "Budget":
            backendType = "budget"
        case "Time extend":
            backendType = "time"
        case "Add member":
            backendType = "resource"
        default:
            backendType = ""
        }

        guard !requestTitle.isEmpty,
              !requestSubject.isEmpty,
              backendType != "" else {
            viewModel.alertMessage = "Please fill all fields"
            viewModel.showAlert = true
            return
        }

        viewModel.sendRequest(
            title: requestTitle,
            requestType: backendType,
            details: requestSubject,
            value: count
        )
    }
}


//# MARK: - Reusable Input Field
struct ReqInputField: View {

    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            TextField(placeholder, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5))
                )
        }
    }
}


