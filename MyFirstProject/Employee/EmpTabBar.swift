//
//  EmpTabbar.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI


struct EmpTab: View {
    
    @Binding var path:NavigationPath
   
    
    var body: some View {
        TabView {

            // Home
            EmpDashboardView(path: $path)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

          
            MyTasksView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Projects")
                }

           
            ScheduleView(path: $path)
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Team")
                }

            
            EmpProfileView(path: $path)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }

         }
        .tint(Color(hex: "#FDB913")) // active tab color
    }
}
