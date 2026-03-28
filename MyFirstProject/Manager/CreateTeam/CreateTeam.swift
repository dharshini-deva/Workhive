import SwiftUI

// MARK: - Create Team View
struct CreateTeamView: View {

    @Binding var path: NavigationPath

    @StateObject private var viewModel = CreateTeamViewModel()

    @State private var teamName = ""
    @State private var showAlert = false

    @State private var selectedManagers: [TeamUser] = []
    @State private var selectedMembers: [TeamUser] = []

    @State private var showManagerPicker = false
    @State private var showMemberPicker = false

    @AppStorage("managerId") private var creatorId: String = ""
    @AppStorage("selectedProjectId") var projectId: Int = 0


//    private let creatorId = UserDefaults.standard.integer(forKey: "loggedInUserId")
//    private let projectId = UserDefaults.standard.integer(forKey: "selectedProjectId")

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text("Create Team")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Team Name
                    CTInputField(
                        title: "Team Name",
                        placeholder: "Enter Team Name",
                        text: $teamName
                    )

                    // Managers
                    SectionHeader(title: "Managers", subtitle: "(Selected)")
                    ManagerCard(
                        users: selectedManagers,
                        onAddTap: { showManagerPicker = true }
                    )

                    // Members
                    SectionHeader(title: "Members", subtitle: "(Selected)")
                    MembersGrid(
                        users: selectedMembers,
                        onAddTap: { showMemberPicker = true }
                    )
                }
                .padding()
            }

            // Create Button
            Button(action: createTeam) {
                if viewModel.isLoading {
                    ProgressView().foregroundColor(.white)
                } else {
                    Text("Create Team")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#FDB913"))
            .cornerRadius(14)
            .padding()
        }
//        .onAppear {
//            print("ProjectId received:", projectId)
//        }

        // Alert (same pattern as Create Project)
        .alert("Alert", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                if viewModel.successMessage != nil {
                    path.append(AppRoute.ManTO)
                }
            }
        } message: {
            Text(viewModel.successMessage ?? viewModel.errorMessage ?? "Something went wrong")
        }

        // Manager Picker
        .sheet(isPresented: $showManagerPicker) {
            NavigationStack {
                ManagerPickerView { manager in
                    if !selectedManagers.contains(where: { $0.id == manager.id }) {
                        selectedManagers.append(manager)
                    }
                }
            }
        }

        // Member Picker
        .sheet(isPresented: $showMemberPicker) {
            NavigationStack {
                MemberPickerView { member in
                    if !selectedMembers.contains(where: { $0.id == member.id }) {
                        selectedMembers.append(member)
                    }
                }
            }
        }
    }

    // API Call
    private func createTeam() {
        viewModel.createTeam(
            creatorId: Int(creatorId) ?? 0,
            projectId: projectId,
            teamName: teamName,
            managerIds: selectedManagers.map { $0.id },
            memberIds: selectedMembers.map { $0.id }
        ) { success in
            if success {
                path.append(AppRoute.ManTO)
            } else {
                showAlert = true
            }
        }
    }
}

//
// MARK: - UI Components
//

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundColor(.gray)
        }
    }
}

struct CTInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            TextField(placeholder, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5))
                )
        }
    }
}

struct ManagerCard: View {

    let users: [TeamUser]
    let onAddTap: () -> Void

    var body: some View {
        HStack(spacing: 20) {

            ForEach(users) { user in
                ProfileItem(
                    name: user.fullName,
                    role: "Manager",
                    profileImage: user.profileImage,
                    isAdd: false
                )
            }

            Button(action: onAddTap) {
                ProfileItem(
                    name: "Add",
                    role: "Manager",
                    profileImage: nil,
                    isAdd: true
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}


struct MembersGrid: View {

    let users: [TeamUser]
    let onAddTap: () -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {

            ForEach(users) { user in
                ProfileItem(
                    name: user.fullName,
                    role: "Member",
                    profileImage: user.profileImage,
                    isAdd: false
                )
            }

            Button(action: onAddTap) {
                ProfileItem(
                    name: "Add",
                    role: "Member",
                    profileImage: nil,
                    isAdd: true
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4))
        )
    }
}


struct ProfileItem: View {

    let name: String
    let role: String
    let profileImage: String?
    let isAdd: Bool

    var body: some View {
        VStack(spacing: 8) {

            if isAdd {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.gray)
                    )

            } else {
                AsyncImage(
                    url: URL(string: ServiceApi.BaseUrl + (profileImage ?? ""))
                ) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    default:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            }

            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(role)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


// MARK: - Picker Screens (DYNAMIC)

struct ManagerPickerView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ManagerPickerViewModel()

    let onSelect: (TeamUser) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading managers...")
                    .padding()

            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()

            } else {
                List(viewModel.managers) { manager in
                    Button {
                        onSelect(manager)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {

                            // ✅ Async Image from DB
                            AsyncImage(
                                url: URL(string: ServiceApi.BaseUrl + (manager.profileImage ?? ""))
                            ) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()

                                default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                            // Text info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(manager.fullName)
                                    .fontWeight(.medium)

                                Text(manager.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Select Manager")
        .onAppear {
            viewModel.fetchManagers()
        }
    }
}


struct MemberPickerView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = MemberPickerViewModel()

    let onSelect: (TeamUser) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading members...")
                    .padding()

            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()

            } else {
                List(viewModel.members) { member in
                    Button {
                        onSelect(member)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {

                            AsyncImage(
                                url: URL(string: ServiceApi.BaseUrl + (member.profileImage ?? ""))
                            ) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()

                                default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.fullName)
                                    .fontWeight(.medium)

                                Text(member.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Select Member")
        .onAppear {
            viewModel.fetchMembers()
        }
    }
}
