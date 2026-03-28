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

struct HrNotificationsView: View {
    
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

                        HrNotificationCard(
                            title: "Sample Notification",
                            message: "This is Just a Sample Notification to check this feature looks good in Screen or Not",
                            time: "12th Jan 2025 12:00pm"
                        )

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }

            // MARK: - Floating Action Button
            Button(action: {
                
            }) {
                Image(systemName: "")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    
                    .shadow(radius: 6)
            }
            .padding()
        }
        .background(Color.white)
    }
}

// MARK: - Notification Card
struct HrNotificationCard: View {

    let title: String
    let message: String
    let time: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 42, height: 42)
                .foregroundColor(.gray)

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


