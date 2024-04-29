//
//  Endpoint.swift
//
//
//  Created by Michael Eid on 4/26/24.
//

import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: Headers { get }
    var parameters: RequestParameters? { get }
}

extension Endpoint {

    var headers: Headers { .default }

    func asURLRequest() -> URLRequest? {
        let urlPath = baseURL.appendingPathComponent(path)
        var bodyData: Data? = nil
        var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: false)
        switch parameters {
        case let .query(parameters):
            urlComponents?.queryItems = parameters.compactMapValues { $0 }.map {
                URLQueryItem(name: $0.key, value: $0.value.value) }
        case let .body(body):
            let json = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
            bodyData = json
        case let .data(data):
            bodyData = data
        default:
            break
        }

        guard let requestUrl = urlComponents?.url?.absoluteURL else { return nil }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue.uppercased()
        request.allHTTPHeaderFields = Headers.default.merging(headers, uniquingKeysWith: { _, new in new })
        request.httpBody = bodyData

        return request
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authentication"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case authorization = "Authorization"
    case acceptLanguage = "Accept-Language"
    case userAgent = "User-Agent"
}

enum ContentType: String {
    case json = "application/json"
    case xwwwformurlencoded = "application/x-www-form-urlencoded"
}

enum HTTPMethod: String {
    case get, head, post, put, delete, connect, options, trace, patch
}

enum NetworkError: LocalizedError, Equatable {
    case failedToConstructRequest
    case invalidBody
    case invalidEndpoint
    case invalidURL
    case emptyData
    case invalidJSON
    case invalidResponse
    case unauthorized
    case networkFailure
    case timeout
    case unknown
    case statusCode(Int)
}
