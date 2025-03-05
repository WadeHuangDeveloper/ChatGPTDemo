//
//  OpenAIChatStreamResponse.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation

struct OpenAIChatStreamResponse: Codable {
    let id: String
    let object: String
    let created: TimeInterval
    let model: String
    let serviceTier: String?
    let systemFingerprint: String?
    let choices: [OpenAIChatChoice]
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case serviceTier = "service_tier"
        case systemFingerprint = "system_fingerprint"
        case choices
    }
    
    static func from(streamString: String) -> [Self]? {
        guard !streamString.isEmpty else { return nil }
        
        let rawStreamStrings = streamString
            .components(separatedBy: "data:")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var responses: [Self] = []
        for rawStreamString in rawStreamStrings {
            guard !rawStreamString.contains("[DONE]"),
                  let jsonData = rawStreamString.data(using: .utf8) else { continue }
            
            do {
                let response = try JSONDecoder().decode(Self.self, from: jsonData)
                responses.append(response)
            } catch {
                print("JSON decode error: \(error.localizedDescription)")
                return nil
            }
        }
        return responses
    }
}

struct OpenAIChatChoice: Codable {
    let index: Int
    let delta: OpenAIChatDelta
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case delta
        case finishReason = "finish_reason"
    }
}

struct OpenAIChatDelta: Codable {
    let role: String?
    let content: String?
}
