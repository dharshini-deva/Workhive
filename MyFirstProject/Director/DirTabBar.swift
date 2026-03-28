
import SwiftUI


struct DirTab: View {
    
    @Binding var path:NavigationPath
    
    var body: some View {
        TabView {

            DirectorDashboardView(path: $path)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
          
            ProjectsView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Projects")
                }

            DirTeamsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Team")
                }

            DirProfileView(path: $path)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }

            }
        .tint(Color(hex: "#FDB913")) // active tab color
    }
}
