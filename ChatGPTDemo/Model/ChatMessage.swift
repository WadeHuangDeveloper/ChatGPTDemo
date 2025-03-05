//
//  ChatMessage.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation
import MessageKit

struct ChatMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
