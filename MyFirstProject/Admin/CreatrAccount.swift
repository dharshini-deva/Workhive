//
//  CreateAccount.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct CreateAccountView: View {

    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // MARK: - Title
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // MARK: - Role Cards
                    VStack(spacing: 20) {
                      

                            Button {
                                // Create Manager account
                                path.append((AppRoute.createacc("Manager")))
                            } label: {
                                CreateAccountCard(role: "Manager")
                            }
                            .buttonStyle(.plain)

                            Button {
                                // Create HR account
                                print("HR tapped")
                                path.append((AppRoute.createacc("HR")))
                            } label: {
                                CreateAccountCard(role: "HR")
                            }
                            .buttonStyle(.plain)

                            Button {
                                // Create Employee account
                                path.append((AppRoute.createacc("Employee")))
                            } label: {
                                CreateAccountCard(role: "Employee")
                            }
                            .buttonStyle(.plain)

                            Button {
                                path.append((AppRoute.createacc("Director")))
                                print("Director tapped")
                            } label: {
                                CreateAccountCard(role: "Director")
                            }
                            .buttonStyle(.plain)
                        

                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .background(Color.orange.opacity(0.12))
    }
}

//////////////////////////////////////////////////////////
// MARK: - Components
//////////////////////////////////////////////////////////

struct CreateAccountCard: View {

    let role: String
    
    

    var body: some View {
        HStack(spacing: 20) {

            // Role Icon
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 46, height: 46)
                .foregroundColor(.gray)

            // Role Name
            Text(role)
                .font(.headline)

            Spacer()

            // Create Button
//            Button(action: {
//
//                // Navigate to Create Form for selected role
//
//            }) {
//                Text("Create\nAccount")
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 22)
//                    .padding(.vertical, 12)
//                    .background(Color.orange)
//                    .cornerRadius(12)
//            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(18)
    }
}
