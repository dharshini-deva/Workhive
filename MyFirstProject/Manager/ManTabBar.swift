//
//  EmpTabbar.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI


struct ManTab: View {
    
    @Binding var path:NavigationPath
    
    var body: some View {
        TabView {

            // Home
            ManDashboardView(path: $path)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

          
            ManProjectsView(path: $path)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Projects")
                }

           
            ManTeamsView(path:$path)
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Team")
                }

            
            ManProfileView(path: $path)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }

            }
        .tint(Color(hex: "#FDB913")) // active tab color
    }
}

