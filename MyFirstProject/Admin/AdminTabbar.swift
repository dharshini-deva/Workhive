//
//  AdminTabbar.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

//
//  EmpTabbar.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI


struct AdminTab: View {
    
    @Binding var path:NavigationPath
    
    var body: some View {
        TabView {

            // Home
            AdminHomeView(path: $path)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

          
            CreateAccountView(path: $path)
                .tabItem {
                    Image(systemName: "person")
                    Text("Create Account")
                }


            
            AdminProfileView(path: $path)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }

            }
       
        .tint(Color(hex: "#FDB913"))
    }
}
