import SwiftUI

struct EmpProfileView: View {

    @Binding var path: NavigationPath
    @State private var showLogoutAlert = false
    
    // Edit State
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedPhone = ""
    @State private var editedDob = Date()
    @State private var showValidationError = false
    @State private var validationMessage = ""

    @StateObject private var viewModel = EmpProfileViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
                
                // Edit button removed
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView(showsIndicators: false) {

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.top, 40)
                }

                if let user = viewModel.userData {
                  
                    VStack(spacing: 28) {

                        // MARK: - Profile Photo
                        VStack(spacing: 12) {
                            AsyncImage(url: URL(string: ServiceApi.BaseUrl+"\(user.profileImage)")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 110, height: 110)

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())

                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 110, height: 110)
                                        .foregroundColor(.gray)

                                @unknown default:
                                    EmptyView()
                                }
                            }

                            //Text(user.fullName)
                              //  .font(.headline)
                        }


                        // MARK: - Profile Details
                        VStack(alignment: .leading, spacing: 22) {

                            EditableProfileField(
                                title: "Full Name",
                                text: $editedName,
                                isEditing: isEditing,
                                date: .constant(Date())
                            )
                            
                            // Role is usually not editable by employee
                            EditableProfileField(
                                title: "Role",
                                text: .constant(user.role),
                                isEditing: false, 
                                date: .constant(Date())
                            )
                            
                            EditableProfileField(
                                title: "Date of Birth",
                                text: .constant(""),
                                isEditing: isEditing,
                                isDate: true,
                                date: $editedDob
                            )
                            
                            EditableProfileField(
                                title: "Phone Number",
                                text: $editedPhone,
                                isEditing: isEditing,
                                keyboardType: .numberPad,
                                date: .constant(Date())
                            )
                            
                            EditableProfileField(
                                title: "Email Address",
                                text: $editedEmail,
                                isEditing: isEditing,
                                keyboardType: .emailAddress,
                                date: .constant(Date())
                            )
                        }

                        // MARK: - Logout
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Text("Logout")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#FDB913"))
                                .cornerRadius(14)
                        }
                        .alert("Logout", isPresented: $showLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Logout", role: .destructive) {
                                path.append(AppRoute.login)
                            }
                        } message: {
                            Text("Are you sure want to logout?")
                        }
                    }
                    .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            viewModel.getProfile()
        }
        .onChange(of: viewModel.userData?.id) { _ in
            // Sync initial state data when loaded
            if let user = viewModel.userData {
                editedName = user.fullName
                editedEmail = user.email
                editedPhone = user.phone
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: user.dob) {
                    editedDob = date
                }
            }
        }
        .alert("Validation Error", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    private func startEditing() {
        guard let user = viewModel.userData else { return }
        editedName = user.fullName
        editedEmail = user.email
        editedPhone = user.phone
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: user.dob) {
            editedDob = date
        }
        
        isEditing = true
    }
    
    private func saveProfile() {
        // Validation
        if editedName.isEmpty {
            validationMessage = "Name cannot be empty"
            showValidationError = true
            return
        }
        
        if !editedEmail.isValidEmail {
            validationMessage = "Please enter a valid email address"
            showValidationError = true
            return
        }
        
        if !editedPhone.isValidPhone {
            validationMessage = "Please enter a valid 10-digit phone number"
            showValidationError = true
            return
        }
        
        // TODO: Call Update API
        // For now just toggle editing off and show a message or simulated success
        // viewModel.updateProfile(...) 
        
        isEditing = false
    }
}
