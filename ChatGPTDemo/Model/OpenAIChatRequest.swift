//
//  OpenAIChatRequest.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let stream: Bool
}

struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}
