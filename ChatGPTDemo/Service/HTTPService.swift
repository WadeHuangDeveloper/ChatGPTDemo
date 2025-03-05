//
//  HTTPService.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import Foundation
import Alamofire

class HTTPService {
    static let shared = HTTPService()
    
    private init() {
        
    }
    
    func streamRequest(apiKey: String, url: URL, parameters: Codable) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let headers: HTTPHeaders = [
                    HTTPServiceHeader.Key.Authorization: "\(HTTPServiceHeader.Value.Bearer) \(apiKey)",
                    HTTPServiceHeader.Key.ContentType: "\(HTTPServiceHeader.Value.ApplicationJson)",
                ]
                AF.streamRequest(url,
                                 method: .post,
                                 parameters: parameters,
                                 encoder: .json,
                                 headers: headers,
                                 automaticallyCancelOnStreamError: true).responseStreamString { stream in
                    switch stream.event {
                    case .stream(let result):
                        continuation.yield(result.get())
                    case .complete:
                        continuation.finish()
                    }
                }
            }
        }
    }
}
