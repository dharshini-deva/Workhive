//
//  ManTeams.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

//
//  DirTeam.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct ManTeamDetailView: View {

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack(spacing: 12) {
                

                Text("Team A")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)

                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // MARK: - Managers
                    Text("Managers")
                        .font(.title3)
                        .fontWeight(.bold)

                    ManagerView(
                        imageName: "person.circle.fill",
                        name: "Sarah Williams",
                        role: "Team Lead"
                    )

                    // MARK: - Team Members
                    Text("Team Members")
                        .font(.title3)
                        .fontWeight(.bold)

                    HStack(spacing: 26) {
                        MemberView(name: "Sarah Williams", role: "Team Lead")
                        MemberView(name: "Sarah Williams", role: "Team Lead")
                        MemberView(name: "Sarah Williams", role: "Team Lead")
                    }

                    // MARK: - Project Details
                    Text("Project Details")
                        .font(.title3)
                        .fontWeight(.bold)

                    ProjectDetailCard(
                        title: "Mobile App Redesign",
                        progress: 0.75
                    )

                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .background(Color.white)
    }
}

// MARK: - Manager View
struct ManManagerView: View {
    let imageName: String
    let name: String
    let role: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
                .clipShape(Circle())

            Text(name)
                .font(.headline)

            Text(role)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
// MARK: - Member View
struct ManMemberView: View {
    let name: String
    let role: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.gray)
                .clipShape(Circle())

            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(role)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
// MARK: - Project Detail Card
struct ManProjectDetailCard: View {
    let title: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .foregroundColor(.gray)
                }

                ProgressView(value: progress)
                    .tint(Color(hex: "#FDB913"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}

#Preview {
    ManTeamDetailView()
}
