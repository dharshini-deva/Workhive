import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CreateProfileView: View {

    // MARK: - Alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Profile Image
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil

    // MARK: - Resume Picker
    @State private var showResumePicker = false
    @State private var resumeURL: URL? = nil

    @StateObject private var viewModel = AdminCreateViewModel()

    var type: String = ""   // HR / Manager / Employee / Director
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Create Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {

                    // MARK: - Profile Photo
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if let selectedImage {
                                    selectedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 110, height: 110)
                                        .foregroundColor(.gray)
                                }

                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        Text("Profile Photo")
                            .font(.headline)
                    }

                    // MARK: - Form Fields
                    VStack(spacing: 20) {
                        InputField(title: "Full Name", text: $viewModel.fullName)
                        InputField(title: "Role", text: $viewModel.selectedRole)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date of Birth").font(.headline)
                            DatePicker(
                                "",
                                selection: $viewModel.dob,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.4))
                            )
                        }
                        
                        VerifiedField(title: "Phone Number", text: $viewModel.phone)
                        VerifiedField(title: "Email Address", text: $viewModel.email)
                        VerifiedSecureField(title: "Password", text: $viewModel.password)
                    }

                    // MARK: - Resume Upload
                    VStack(spacing: 8) {
                        Button {
                            showResumePicker = true
                        } label: {
                            Text(resumeURL == nil ? "Upload Resume" : "Change Resume")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#FDB913"))
                                .cornerRadius(14)
                        }

                        if let resumeURL {
                            Text(resumeURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // MARK: - Create Button
                    Button {
                        // MARK: - Local Validation
                        if viewModel.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "Please enter full name"
                            showAlert = true
                            return
                        }
                        
                        if !viewModel.email.isValidEmail {
                            alertMessage = "Please enter a valid email address"
                            showAlert = true
                            return
                        }
                        
                        if !viewModel.phone.isValidPhone {
                            alertMessage = "Please enter a valid 10-digit phone number"
                            showAlert = true
                            return
                        }
                        
                        if viewModel.password.count < 6 {
                            alertMessage = "Password must be at least 6 characters long"
                            showAlert = true
                            return
                        }
                        
                        viewModel.createUser(
                            adminId: 1,
                            role: viewModel.selectedRole,
                            fullName: viewModel.fullName,
                            email: viewModel.email,
                            password: viewModel.password,
                            phone: viewModel.phone,
                            dob: viewModel.dob,
                            profileImage: selectedImage,
                            resumeURL: resumeURL
                        ) { success, message in
                            DispatchQueue.main.async {
                                alertMessage = success
                                    ? "\(viewModel.selectedRole) account created successfully"
                                    : message
                                showAlert = true
                            }
                        }
                    } label: {
                        Text("Create")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.25))
                            .cornerRadius(14)
                    }
                }
                .padding()
            }
        }
        .background(Color.white)

        // MARK: - Alert
        .alert("Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    path.removeLast()
                }
            }
        } message: {
            Text(alertMessage)
        }

        // MARK: - Initial Role
        .task {
            viewModel.selectedRole = type
        }

        // MARK: - Image Picker Handler
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }

        // MARK: - Resume Picker
        .fileImporter(
            isPresented: $showResumePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let files) = result {
                resumeURL = files.first
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: - Components
//////////////////////////////////////////////////////////

struct InputField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            TextField(placeholder, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4))
                )
        }
    }
}

struct VerifiedField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            HStack {
                TextField("", text: $text)
                    .padding(.leading)
                //checkmark
            }
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
    }

//    private var checkmark: some View {
//        Circle()
//            .fill(Color(hex: "#FDB913"))
//            .frame(width: 28, height: 28)
//            .overlay(
//                Image(systemName: "checkmark")
//                    .foregroundColor(.white)
//            )
//            .padding(.trailing, 10)
//    }
}

struct VerifiedSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            HStack {
                SecureField("", text: $text)
                    .padding(.leading)
                //checkmark
            }
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
    }

//    private var checkmark: some View {
//        Circle()
//            .fill(Color(hex: "#FDB913"))
//            .frame(width: 28, height: 28)
//            .overlay(
//                Image(systemName: "checkmark")
//                    .foregroundColor(.white)
//            )
//            .padding(.trailing, 10)
//    }
}

//////////////////////////////////////////////////////////
// MARK: - Preview
//////////////////////////////////////////////////////////
//
//struct CreateProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateProfileView(
//            type: "Employee",
//            path: .constant(NavigationPath())
//        )
//    }
//}
