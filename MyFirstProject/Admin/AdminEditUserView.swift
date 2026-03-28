import SwiftUI
import Combine

struct AdminEditUserView: View {
    let user: AdminUser
    @Binding var path: NavigationPath
    
    @State private var fullName: String
    @State private var email: String
    @State private var phone: String
    @State private var role: String
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    init(user: AdminUser, path: Binding<NavigationPath>) {
        self.user = user
        self._path = path
        self._fullName = State(initialValue: user.full_name)
        self._email = State(initialValue: user.email)
        self._phone = State(initialValue: user.phone)
        self._role = State(initialValue: user.role)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Button(action: { path.removeLast() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Text("Edit User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    InputField(title: "Full Name", text: $fullName)
                    InputField(title: "Role", text: $role) // Typically role changing might be restricted or require a picker
                    VerifiedField(title: "Email", text: $email)
                    VerifiedField(title: "Phone", text: $phone)
                    
                    Button {
                        updateUser()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Update")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FDB913"))
                    .cornerRadius(14)
                    .disabled(isLoading)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("success") {
                    path.removeLast()
                }
            })
        }
    }
    
    func updateUser() {
        // Basic Validation
        if fullName.isEmpty || email.isEmpty || phone.isEmpty {
            alertMessage = "All fields are required"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let parameters: [String: String] = [
            "user_id": user.id,
            "full_name": fullName,
            "email": email,
            "phone": phone,
            "role": role
        ]
        
        APIClient.shared.postFormData(
            urlString: ServiceApi.updateAdminUser, // Ensure this endpoint exists
            parameters: parameters
        )
        .sink { completion in
            isLoading = false
            if case .failure(let error) = completion {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        } receiveValue: { (response: CommonResponse) in
            isLoading = false
            alertMessage = response.message
            showAlert = true
        }
        .store(in: &cancellables)
    }
    
    // Quick fix for cancellables since this is a View, usually better in ViewModel
    @State private var cancellables = Set<AnyCancellable>()
}
