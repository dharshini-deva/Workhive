//
//  OpenRouterRequest.swift
//  WorkHive
//
//  Created by SAIL on 23/01/26.
//


import Foundation
import Combine

struct OpenRouterRequest: Encodable {
    let model: String
    let messages: [OpenRouterMessage]
}

struct OpenRouterMessage: Encodable {
    let role: String
    let content: String
}

struct OpenRouterResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class WorkHiveAIService {

    private let apiKey = "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"

    func sendMessage(_ text: String) -> AnyPublisher<String, Error> {

        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = OpenRouterRequest(
            model: "openai/gpt-4o-mini",
            messages: [
                OpenRouterMessage(
                    role: "system",
                    content: """
                    You are WorkHive Assistant, an in-app AI helper for employees.

                    HELP WITH:
                    - Tasks & reminders
                    - Daily report updates
                    - Leave process
                    - App navigation
                    - Productivity tips

                    RULES:
                    - No medical or legal advice
                    - No data modification
                    - Be short and professional

                    STYLE:
                    - Friendly office assistant
                    - Clear steps
                    - Simple English
                    """
                ),
                OpenRouterMessage(role: "user", content: text)
            ]
        )

        request.httpBody = try? JSONEncoder().encode(body)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: OpenRouterResponse.self, decoder: JSONDecoder())
            .tryMap {
                $0.choices.first?.message.content ?? "No response"
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
