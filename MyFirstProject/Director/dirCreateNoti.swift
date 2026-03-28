//
//  DirCreateNoti.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

//
//  ManCreateNoti.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI

struct DirCreateNotificationView: View {
    
    @Binding var path: NavigationPath

    // MARK: - State
    @State private var title: String = ""
    @State private var description: String = ""

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(.headline)

                        TextField("Enter Project Title", text: $title)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                    }

                    // MARK: - Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)

                        TextEditor(text: $description)
                            .frame(height: 200)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                            .overlay(
                                Group {
                                    if description.isEmpty {
                                        Text("Enter Project Description")
                                            .foregroundColor(.gray.opacity(0.7))
                                            .padding(.top, 14)
                                            .padding(.leading, 16)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }

                    // MARK: - Upload Files
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upload Files")
                            .font(.headline)

                        VStack(spacing: 12) {
                            Image(systemName: "icloud.and.arrow.up")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("Click here to Upload Files")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.5))
                        )
                    }

                    // MARK: - Send Notification Button
                    Button(action: {
                        // send notification action
                    }) {
                        Text("Send Notification")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .background(Color.white)
    }
}


