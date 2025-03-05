//
//  OpenAIService.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation
import MessageKit

class OpenAIService {
    static let shared = OpenAIService()
    private var responseContent = ""
    
    private init() {
        
    }
    
    func chat(content: String) -> AsyncThrowingStream<ChatMessage, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: OpenAI.API.Chat) else {
                        throw HTTPServiceError.InvalidURL
                    }
                    let message = OpenAIChatMessage(role: "user", content: content)
                    let parameters = OpenAIChatRequest(model: OpenAI.Model.GPT35Turbo, messages: [message], stream: true)
                    
                    responseContent = ""
                    let chatSender = ChatSender(senderId: "gpt", displayName: "ChatGPT")
                    for try await responseStreamString in HTTPService.shared.streamRequest(apiKey: OpenAI.APIKey, url: url, parameters: parameters) {
                        print("\(Self.self) Line: \(#line) responseStreamString: \(responseStreamString)")
                        if let responses = OpenAIChatStreamResponse.from(streamString: responseStreamString),
                           let response = responses.first {
                            let messageId = response.id
                            let sentDate =  Date(timeIntervalSince1970: response.created)
                            let contents = responses.compactMap { $0.choices.first?.delta.content }.joined()
                            responseContent += contents
                            let chatMessage = ChatMessage(sender: chatSender,
                                                          messageId: messageId,
                                                          sentDate: sentDate,
                                                          kind: .text(responseContent))
                            continuation.yield(chatMessage)
                        }
                    }
                    continuation.finish()
                } catch {
                    print("\(Self.self) error: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
