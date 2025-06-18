//
//  Router.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/4/25.
//

import Alamofire
import Foundation

protocol Router: URLRequestConvertible {
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }

    func asURLRequest() throws -> URLRequest
}

extension Router {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method

        switch method {
        case .get:
            if let parameters = parameters {
                request = try URLEncoding.default.encode(request, with: parameters)
            }
        default:
            if let parameters = parameters {
                request = try JSONEncoding.default.encode(request, with: parameters)
            }
        }
        
        print("👉 url: \(request)")
        
        return request
    }
}
