//
//  NetworkingService.swift
//
//
//  Created by Michael Eid on 4/26/24.
//

import Combine
import Foundation

protocol NetworkServiceType {
    var session: URLSession { get set }
    associatedtype EndpointType: Endpoint
    func request<T: Decodable> (_ endpoint: EndpointType) -> AnyPublisher<T, Error>
}

protocol CodableNetworkServiceType: NetworkServiceType {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
}

struct NetworkService<EndpointType: Endpoint> : CodableNetworkServiceType {
    var session: URLSession
    var decoder: JSONDecoder { SampleAPI.decoder }
    var encoder: JSONEncoder { SampleAPI.encoder }
    var requestCache: URLCache? { session.configuration.urlCache }
    var usingCache: Bool

    init(_ session: URLSession = SampleAPI.session, usingCache: Bool = false) {
        self.session = session
        self.usingCache = usingCache
    }

    func request<T>(_ endpoint: EndpointType) -> AnyPublisher<T, any Error> where T : Decodable {
        return requestData(endpoint)
            .tryMap { try self.validate($0, $1) }
            .map(\.0)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func requestData(_ endpoint: EndpointType) -> AnyPublisher<(Data, URLResponse), Error> {
        guard var request = endpoint.asURLRequest() else {
            return Fail(error: NetworkError.failedToConstructRequest).eraseToAnyPublisher()
        }
        request.httpMethod = endpoint.method.rawValue

        if let requestCache, let cached = requestCache.cachedResponse(for: request) {
            return Just((data: cached.data, response: cached.response))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .mapError(errorFromCode(from:))
            .handleEvents(receiveOutput: {
                self.requestCache?.storeCachedResponse(.init(response: $1, data: $0), for: request)
            })
            .eraseToAnyPublisher()
    }

    func validate(_ data: Data, _ response: URLResponse) throws -> (Data, HTTPURLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        return (data, httpResponse)
    }

    func errorFromCode(from urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet:
            return NetworkError.networkFailure
        case .timedOut:
            return NetworkError.timeout
        default:
            return NetworkError.statusCode(urlError.errorCode)
        }
    }
}

enum SampleAPI {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static let session: URLSession = {
        let configuration: URLSessionConfiguration = .default
        return URLSession(configuration: configuration)
    }()
}
