//
//  HrDashboard.swift
//  WorkHive
//
//  HR Dashboard – FINAL (As Requested)
//

import SwiftUI
import Combine

struct DashboardView: View {

    // MARK: - State
    @State private var searchText: String = ""
    @AppStorage("hrId") private var hrId: String = ""
    @AppStorage("employeeId") private var employeeId: String = ""

    // ✅ CORRECT ViewModel (LIST)
    @StateObject private var employeeVM = HrEmployeeViewModel()

    // MARK: - Navigation
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        Text("Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()
                    }
                    .padding(.horizontal)

                    // MARK: - Profile Card
                    Button {
                        path.append(AppRoute.hrpro)
                    } label: {
                        HStack(spacing: 16) {

                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 56, height: 56)
                                .foregroundColor(.gray)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome Back")
                                    .foregroundColor(.gray)

                                Text("Alex Williams")
                                    .font(.headline)
                            }

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // MARK: - Quick Actions
                    Text("Quick Actions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    HStack(spacing: 16) {

                        Button {
                            path.append(AppRoute.hrLeave)
                        } label: {
                            QuickActionCard(
                                title: "Leave Requests",
                                color: Color.blue.opacity(0.15),
                                textColor: .blue
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            path.append(AppRoute.Hrnotifi)
                        } label: {
                            QuickActionCard(
                                title: "Notifications",
                                color: Color.orange.opacity(0.15),
                                textColor: .orange
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    // MARK: - Employee Directory
                    Text("Employee Directory")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // Search Bar (UI only – logic optional)
                    TextField("Search employees...", text: $searchText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .padding(.horizontal)

                    // MARK: - Employee List
                    VStack(spacing: 14) {

                        if employeeVM.isLoading {
                            ProgressView().padding()
                        }

                        if let error = employeeVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }

                        ForEach(employeeVM.employees) { user in
                            Button {
                                employeeId = String(user.id)   // ✅ correct
                                path.append(AppRoute.hrEmployeeDetail)
                            } label: {
                                EmployeeRow(user: user)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .onAppear {
                employeeVM.fetchEmployees()
            }
        }
        .background(Color.orange.opacity(0.1))
    }
}

//
// MARK: - Quick Action Card
//
struct QuickActionCard: View {
    let title: String
    let color: Color
    let textColor: Color

    var body: some View {
        Text(title)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(color)
            .cornerRadius(14)
    }
}

//
// MARK: - Employee Row
struct EmployeeRow: View {

    let user: HrUser

    var body: some View {

        HStack(spacing: 14) {

            AsyncImage(url: profileImageURL(user.profile_image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 48, height: 48)

                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())

                default:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.full_name).font(.headline)
                Text(user.role).foregroundColor(.gray)
                Text(user.status_text)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

