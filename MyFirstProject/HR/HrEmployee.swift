//
//  HrEmployee.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  HrEmployee.swift
//

import SwiftUI
import Combine

func profileImageURL(_ path: String?) -> URL? {
    guard let path, !path.isEmpty else { return nil }

    if path.hasPrefix("http") {
        return URL(string: path)
    } else {
        return URL(string: ServiceApi.BaseUrl + path)
    }
}

 struct EmployeeDetailsView: View {
    
    @AppStorage("employeeId") private var employeeId: String = ""
    @StateObject private var vm = HrEmployeeDetailViewModel()

    var body: some View {

        VStack {

            if vm.isLoading {
                ProgressView()
            }
            else if let emp = vm.employee {

                VStack(spacing: 20) {
                    

                    AsyncImage(url: profileImageURL(emp.profile_image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)

                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())

                        default:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                    }

                    ReadOnlyField(title: "Full Name", value: emp.full_name)
                    ReadOnlyField(title: "Role", value: emp.role)
                    ReadOnlyField(title: "Phone", value: emp.phone)
                    ReadOnlyField(title: "Email", value: emp.email)
                    ReadOnlyField(title: "Status", value: emp.status_text)
                }
                .padding()
            }

            Spacer()
        }
        .onAppear {
            vm.fetchEmployeeDetail(employeeId: employeeId)
        }
    }
}


// MARK: - ReadOnlyField
struct ReadOnlyField: View {

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4))
                )
        }
    }
}
