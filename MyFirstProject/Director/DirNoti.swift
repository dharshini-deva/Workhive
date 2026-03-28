//
//  DirNotification.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

//
//  ManNotification.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct DirNotificationsView: View {
    
    @StateObject private var viewModel = DirNotificationViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            VStack(spacing: 0) {

                // MARK: - Header
                HStack(spacing: 12) {
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.15))

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        ForEach(viewModel.notifications) { notification in
                            DirNotificationCard(
                                title: notification.title,
                                message: notification.message,
                                time: notification.createdAt,
                                imageUrl: notification.profileImage
                            )
                        }

                        if viewModel.notifications.isEmpty && !viewModel.isLoading {
                            Text("No notifications yet")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                .refreshable {
                    viewModel.fetchNotifications()
                }
            }

            // MARK: - Floating Action Button
            Button(action: {
                path.append(AppRoute.dirCreatenotifi)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding()
        }
        .background(Color.white)
        .onAppear {
            viewModel.fetchNotifications()
        }
    }
}

// MARK: - Notification Card
struct DirNotificationCard: View {

    let title: String
    let message: String
    let time: String
    let imageUrl: String?

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
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
    }
}


