//
//  EmpNoti.swift
//  MyFirstProject
//
//  Created by MANOJKUMAR M on 10/02/26.
//

//
//  EmpNotification.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.

import SwiftUI

struct NotificationsView: View {

    @Binding var path: NavigationPath
    @StateObject private var viewModel = EmpNotificationModel()

    @AppStorage("employeeId") private var employeeId: String = ""


    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text("Notifications")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    ForEach(viewModel.notifications) { notification in
                        EmpNotificationCard(
                            imageName: "person.circle.fill",
                            title: notification.title,
                            message: notification.message,
                            date: notification.createdAt,
                            imageUrl: notification.profileImage // ✅ Pass Profile Image
                        )
                    }

                    if viewModel.notifications.isEmpty {
                        Text("No notifications yet")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchNotifications(userId: employeeId)
        }
    }
}


//
// MARK: - Notification Card
//
// MARK: - Notification Card
//
struct EmpNotificationCard: View {

    let imageName: String // Keeping this for backward compatibility if needed, though we primarily use imageUrl now
    let title: String
    let message: String
    let date: String
    let imageUrl: String? // ✅ Added imageUrl

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 42, height: 42)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 42, height: 42)
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    Text(date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
    }
}


