//
//  DirTeam.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct TeamDetailView: View {

    let teamId: Int
    @StateObject private var viewModel = DirectorTeamDetailViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text(viewModel.teamName)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    Text("Managers")
                        .font(.title3)
                        .fontWeight(.bold)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.managers) { manager in
                                PersonCardView(person: manager)
                            }
                        }
                        
                    }
                   

                    Text("Team Members")
                        .font(.title3)
                        .fontWeight(.bold)

                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]

                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewModel.members) { member in
                            PersonCardView(person: member)
                        }
                    }


                    Text("Project Details")
                        .font(.title3)
                        .fontWeight(.bold)

                    ProjectDetailCard(
                        title: viewModel.projectTitle,
                        progress: viewModel.progress
                    )
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchTeamDetails(teamId: teamId)
        }
    }
}

struct PersonCardView: View {

    let person: TeamPerson

    var body: some View {
        VStack(spacing: 8) {

            AsyncImage(url: person.imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())

            Text(person.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(person.role)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 100)
    }
}


// MARK: - Manager View
struct ManagerView: View {
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
struct MemberView: View {
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
struct ProjectDetailCard: View {
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
                    .tint((Color(hex: "#FDB913")))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}


