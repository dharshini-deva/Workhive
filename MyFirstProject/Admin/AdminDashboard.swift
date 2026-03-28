//
//  AdminDashboard.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct AdminHomeView: View {

    @State private var selectedRole: String = "All"
    @StateObject private var vm = AdminUserViewModel()

    @Binding var path: NavigationPath

    // ✅ Filtered users based on role
    var filteredUsers: [AdminUser] {
        if selectedRole == "All" {
            return vm.users
        }
        return vm.users.filter { $0.role == selectedRole }
    }

    var body: some View {

        VStack {
            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // MARK: - Role Filter
                    Text("Select Role")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {

                            // ✅ All tab
                            RoleChip(
                                title: "All",
                                selected: selectedRole == "All"
                            ) {
                                selectedRole = "All"
                            }

                            // ✅ Dynamic roles
                            ForEach(vm.roles, id: \.self) { role in
                                RoleChip(
                                    title: role,
                                    selected: selectedRole == role
                                ) {
                                    selectedRole = role
                                }
                            }
                        }
                    }

                    // MARK: - User List
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {

                        VStack(spacing: 16) {
                            ForEach(filteredUsers) { user in
                                AdminUserCard(
                                    user: user,
                                    onEdit: {
                                        path.append(AppRoute.adminuseredit(user))
                                    },
                                    onDelete: {
                                        vm.deleteUser(userId: user.id)
                                    }
                                )
                            }

                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
        .onAppear {
            vm.fetchUsers()
        }
    }
}


//////////////////////////////////////////////////////////
// MARK: - Components
//////////////////////////////////////////////////////////

struct RoleChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(
                    selected ? Color.yellow : Color(.systemGray6)
                )
                .foregroundColor(
                    selected ? .white : .black
                )
                .cornerRadius(20)
        }
    }
}

struct AdminUserCard: View {

    let user: AdminUser
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {

            VStack(alignment: .leading, spacing: 6) {
                Text(user.full_name)
                    .font(.headline)

                Text(user.role)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                Button("Edit") {
                    onEdit()
                }
                .foregroundColor(.blue)

                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}




