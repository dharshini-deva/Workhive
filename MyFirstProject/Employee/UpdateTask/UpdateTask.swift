import SwiftUI

struct UpdateTodayTaskView: View {

    @Binding var path: NavigationPath
    @StateObject private var viewModel = UpdateTaskViewModel()

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    // MARK: - Header
                    Text("Update Today’s Task")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top)
                        
                    // MARK: - Select Project
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Project")
                            .font(.headline)
                            
                        Menu {
                            ForEach(viewModel.projects) { project in
                                Button(project.title) {
                                    viewModel.selectedProjectId = project.id
                                }
                            }
                        } label: {
                            HStack {
                                Text(
                                    viewModel.projects.first(where: { $0.id == viewModel.selectedProjectId })?.title ?? "Select Project"
                                )
                                .foregroundColor(viewModel.selectedProjectId.isEmpty ? .gray : .black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.6))
                            )
                        }
                    }

                    // MARK: - Task Name
                    inputField(
                        title: "Task Name",
                        text: $viewModel.taskName
                    )

                    // MARK: - Status
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Status")
                            .font(.headline)
                            
                        Menu {
                            Button("In Progress") { viewModel.status = "In Progress" }
                            Button("Completed") { viewModel.status = "Completed" }
                            Button("Pending") { viewModel.status = "Pending" }
                        } label: {
                            HStack {
                                Text(viewModel.status.isEmpty ? "Select Status" : viewModel.status)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.6))
                            )
                        }
                    }

                    // MARK: - Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)

                        TextEditor(text: $viewModel.description)
                            .frame(height: 180)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.6))
                            )
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchProjects()
            }

            // MARK: - Update Button
            Button {
                viewModel.submitTask()
            } label: {
                Text(viewModel.isLoading ? "Updating..." : "Update Task")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FDB913"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.alertMessage.contains("successfully") {
                    path.removeLast()
                }
            }
        }
    }
}

// MARK: - Reusable Input Field
private extension UpdateTodayTaskView {

    func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            TextField("", text: text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.6))
                )
        }
    }
}
