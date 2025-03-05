//
//  HTTPServiceError.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation

enum HTTPServiceError: Error {
    case InvalidURL
    case InvalidWithError(Error)
}
