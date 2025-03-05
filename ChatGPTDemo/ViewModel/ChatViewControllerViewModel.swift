//
//  ChatViewControllerViewModel.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation

class ChatViewControllerViewModel {
    @Published var messages: [ChatMessage] = []
    let user: ChatSender = ChatSender(senderId: "user", displayName: "You")
    let gpt: ChatSender = ChatSender(senderId: "gpt", displayName: "ChatGPT")
    
    func chat(content: String) async {
        do {
            let chatMessage = ChatMessage(sender: user, messageId: UUID().uuidString, sentDate: .now, kind: .text(content))
            messages.append(chatMessage)
            
            for try await response in OpenAIService.shared.chat(content: content) {
                print("\(Self.self) response.kind: \(response.kind)")
                if let index = messages.firstIndex(where: { $0.messageId == response.messageId }) {
                    messages[index].kind = response.kind
                } else {
                    messages.append(response)
                }
            }
        } catch {
            let chatMessage = ChatMessage(sender: gpt, messageId: UUID().uuidString, sentDate: .now, kind: .text(error.localizedDescription))
            self.messages.append(chatMessage)
        }
    }
}
