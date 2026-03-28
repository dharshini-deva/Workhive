//
//  AppHomePageView.swift
//  WorkHive
//
//  Created by SAIL on 05/12/25.
//

import SwiftUI

struct AppHomePageView: View {
    
    @Binding var path:NavigationPath
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            Image("WorkForm")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
            
            Button(action: {
                //path.append("login")
                path.append(AppRoute.login)
            }) {
                Text("Get Started")
                    .frame(width: 200, height: 40)
                    .background(.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

//struct AppHomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppHomePageView()
//
//    }
//}
