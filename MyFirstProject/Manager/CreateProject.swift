import SwiftUI

struct AddClientProjectView: View {

    @Binding var path: NavigationPath

    // MARK: - Logged-in Manager ID
    @AppStorage("managerId") var managerId: String = ""

    @State private var showAlert = false

    @StateObject private var viewModel = CreateProjectViewModel()
    
    @AppStorage("selectedProjectId") private var selectedProjectId: Int = 0


    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Add Project")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    ManInputField(
                        title: "Title",
                        placeholder: "Enter Project Title",
                        text: $viewModel.title
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)

                        TextEditor(text: $viewModel.description)
                            .frame(height: 180)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                    }

                    HStack(spacing: 16) {
                        ManInputField(
                            title: "Deadline",
                            placeholder: "YYYY-MM-DD",
                            text: $viewModel.deadline
                        )

                        ManInputField(
                            title: "Review On",
                            placeholder: "YYYY-MM-DD",
                            text: $viewModel.reviewOn
                        )
                    }

                    ManInputField(
                        title: "Budget",
                        placeholder: "Enter Budget",
                        text: $viewModel.budget
                    )

                    Button(action: {
                        submitProject()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .foregroundColor(.white)
                        } else {
                            Text("Assign Project")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FDB913"))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        
            .alert("Alert", isPresented: $showAlert) {
                                      Button("Cancel", role: .cancel) { }
                Button("OK") {
                    path.append(AppRoute.manct)
                }

                                  } message: {
                                      Text(viewModel.errorMessage ?? "")
                                  }
    }

    // MARK: - Submit Project
    private func submitProject() {
        viewModel.createProject(managerId: managerId) { success, message in

            if success, let projectId = viewModel.projectData?.projectId {
                selectedProjectId = projectId
                print(" Project ID saved:", projectId)
            } else {
                print(" Project ID missing")
            }

            viewModel.errorMessage = message
            showAlert = true
        }
    }

}

struct ManInputField: View {
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
