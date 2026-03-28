//
//  chatbot.swift
//  WorkHive
//
//  Created by SAIL on 23/01/26.
//

import SwiftUI

struct EmpChatbotView: View {

    @Binding var path: NavigationPath
    
    @StateObject private var vm = EmpChatbotViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // HEADER
            HStack {
                Text("WorkHive Assistant")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(hex: "#FDB913"))

            // MESSAGES
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(vm.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: vm.messages.count) { _ in
                    if let lastId = vm.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }

            // INPUT BAR
            HStack(spacing: 12) {

                TextField("Ask something…", text: $vm.inputText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                Button {
                    vm.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            vm.inputText.isEmpty ? Color.gray : Color.yellow
                        )
                        .clipShape(Circle())
                }
                .disabled(vm.inputText.isEmpty)
            }
            .padding()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

import SwiftUI

struct ChatBubble: View {

    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            Text(message.text)
                .padding(14)
                .foregroundColor(message.isUser ? .white : .black)
                .background(
                    message.isUser ? Color.yellow : Color(.systemGray6)
                )
                .cornerRadius(18)
                .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
