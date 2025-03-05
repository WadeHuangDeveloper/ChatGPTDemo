//
//  HTTPServiceHeader.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation

struct HTTPServiceHeader {
    struct Key {
        static let Authorization = "Authorization"
        static let ContentType = "Content-Type"
    }
    
    struct Value {
        static let Bearer = "Bearer"
        static let ApplicationJson = "application/json"
    }
}
