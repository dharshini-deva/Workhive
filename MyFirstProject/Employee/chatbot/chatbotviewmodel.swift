//
//  chatbotviewmodel.swift
//  WorkHive
//
//  Created by SAIL on 23/01/26.
//

import SwiftUI
import Combine

class EmpChatbotViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = [
        ChatMessage(
            text: "Hi 👋 I’m your WorkHive Assistant. How can I help today?",
            isUser: false
        )
    ]

    @Published var inputText: String = ""

    private let aiService = WorkHiveAIService()
    private var cancellables = Set<AnyCancellable>()

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""

        let typingId = UUID()
        messages.append(ChatMessage(id: typingId, text: "Typing…", isUser: false))

        aiService.sendMessage(text)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.messages.removeAll { $0.id == typingId }
                    self.messages.append(
                        ChatMessage(text: "⚠️ \(error.localizedDescription)", isUser: false)
                    )
                }
            } receiveValue: { reply in
                self.messages.removeAll { $0.id == typingId }
                self.messages.append(ChatMessage(text: reply, isUser: false))
            }
            .store(in: &cancellables)
    }
}



struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool

    init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}
