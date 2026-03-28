//
//  LoginPage.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI


enum UserRole: String, CaseIterable {
    case Admin = "Admin"
    case Director = "Director"
    case Manager = "Manager"
    case HR = "HR"
    case Employee = "Employee"
    
  
}


   

struct LoginView: View {

   
    @Binding var path:NavigationPath
    

    @State var alert:Bool = false

    private let roles = ["Admin", "Director", "Manager", "HR", "Employee"]
    
    @StateObject var viewModel = LoginViewModel()
    
    @AppStorage("managerId") var managerId: String = "" //manager
    
    @AppStorage("DirectorId") var DirectorId: String = "" //director
    
    @AppStorage("employeeId") var employeeId: String = ""
// employee profile
    
    @AppStorage("hrId") var hrId: String = ""//hr profilr
    
    @AppStorage("AdminId") var AdminId: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                Spacer(minLength: 30)

                // MARK: - App Icon + Title
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow)
                            .frame(width: 52, height: 52)

                        Image(systemName: "cube.box.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                    }

                    Text("Welcome to WorkHive")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Select your role to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // MARK: - Role Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Role Selection")
                        .font(.headline)

                    Menu {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            
                            Button("\(role)") {
                                viewModel.selectedRole = "\(role)"
                                viewModel.selectedRoles = role
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedRole.isEmpty ? "Select Role to Continue" : viewModel.selectedRole)
                                .foregroundColor(viewModel.selectedRole.isEmpty ? .gray : .black)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4))
                        )
                    }
                }

                // MARK: - Email
                inputField(
                    icon: "envelope",
                    placeholder: "Email address",
                    text: $viewModel.email
                )

                // MARK: - Password
                inputField(
                    icon: "lock",
                    placeholder: "Password",
                    text: $viewModel.password,
                    isSecure: true
                )

                // MARK: - Login Button
                Button(action: {
      
                    viewModel.login { success, message in
//                        userID = viewModel.userData?.id ?? "" // Common
                        if success {
                            
                            switch viewModel.selectedRoles {
                            case .Admin:
                                AdminId = viewModel.userData?.id ?? ""
                                path.append(AppRoute.adminlogin)
                                
                            case .Employee:
                                employeeId = viewModel.userData?.id ?? ""
                                path.append(AppRoute.emplogin)

                            case .HR:
                                hrId = viewModel.userData?.id ?? ""
                                path.append(AppRoute.hrlogin)

                                
                            case .Director:
                                DirectorId = viewModel.userData?.id ?? ""
                                path.append(AppRoute.dirlogin)
                                
                            case .Manager:
                                managerId = viewModel.userData?.id ?? ""
                                path.append(AppRoute.manlogin)
                                
                            default:
                            print("1")
                            }
                            
                        }else {
                            alert = true
                        }
                    }
                    
                }) {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FDB913"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 6)


                // MARK: - Terms
                VStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Text("Terms of Service")
                        Text("and")
                        Text("Privacy Policy")
                    }
                    .font(.caption)
                    .foregroundColor(.yellow)
                }
                .padding(.top, 10)

                Spacer(minLength: 30)
            }
            .padding()
            
            .alert("Alert", isPresented: $alert) {
                Button("Ok", role: .cancel) {}
            }message: {
                Text(viewModel.errorMessage ?? "")
            }
            
        }
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.08),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Reusable Input Field
private extension LoginView {

    func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)

            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}

