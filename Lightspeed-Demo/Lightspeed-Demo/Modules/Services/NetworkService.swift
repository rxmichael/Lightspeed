//
//  NetworkService.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/18/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol NetworkServiceType {
    var session: URLSession { get set }
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

protocol CodableNetworkServiceType: NetworkServiceType {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
}

enum NetworkError: Error, Equatable {
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

extension CodableNetworkServiceType {
    func requestModel<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return requestModelPublisher(request)
            .mapError { $0 as Error }
            .tryMap { output in
                return try self.validate(output.data, output.response)
            }
            .map { $0.0 }
            .decode(type: T.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func requestModelPublisher(_ request: URLRequest) -> URLSession.DataTaskPublisher {
        return dataTaskPublisher(for: request)
    }
    
    func get<T: Codable>(with urls: [URL]) -> AnyPublisher<[T], Error> {
        let publisherOfPublishers = Publishers.Sequence<[AnyPublisher<T, Error>], Error>(sequence: urls.map(get))
       return publisherOfPublishers.flatMap(maxPublishers: .max(1), { $0 }).collect().eraseToAnyPublisher()
    }
    
    func get<T: Codable>(with url: URL) -> AnyPublisher<T, Error> {
        return dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error -> NetworkError in
                return self.errorFromCode(from: error)
            }
            .tryMap { try self.validate($0.data, $0.response) }
            .map { $0.0 }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func get<T: Codable>(with request: URLRequest) -> AnyPublisher<T, Error> {
        return dataTaskPublisher(for: request)
            .mapError { error -> NetworkError in
                return self.errorFromCode(from: error)
            }
            .tryMap { try self.validate($0.data, $0.response) }
            .map { $0.0 }
            .decode(type: T.self, decoder: decoder)
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

extension URLComponents {
    /**
     Convenience for common-case API requests
     */
    func appending(path: String, queryItems newQueryItems: [URLQueryItem]? = nil) -> URLComponents {
        var mutable = self
        mutable.path = (mutable.path as NSString).appendingPathComponent(path)
        mutable.queryItems = newQueryItems.map { (self.queryItems ?? []) + $0 }
        return mutable
    }
}

extension URL {
    /// Attempts to construct the URL first from the string
    /// Then from the string by first applying some escaping (some URLs are coming back with spaces in them)
    /// Then throws if both of those fail.
    static func from(string: String) throws -> URL {
        let url = URL(string: string)
            ?? string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap { URL(string: $0) }
        return try url.orThrow(NetworkError.failedToConstructRequest)
    }
}

extension URLRequest {
    static func constructRequest(fromURL url: URL, method: HTTPMethod = .get, bodyData: @autoclosure () throws -> Data? = nil) rethrows -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = try bodyData()
        return request
    }
    
    static func constructRequest(fromComponents components: URLComponents, method: HTTPMethod = .get, bodyData: @autoclosure () throws -> Data? = nil) throws -> URLRequest {
        guard let url = components.url else {
            throw NetworkError.failedToConstructRequest
        }
        return try constructRequest(fromURL: url, method: method, bodyData: bodyData())
    }
}

extension CodableNetworkServiceType {
    func constructRequest<T: Encodable>(fromURL url: URL, method: HTTPMethod = .get, model: T) throws -> URLRequest {
        return try URLRequest.constructRequest(fromURL: url, method: method, bodyData: encoder.encode(model))
    }
    
    func constructRequest<T: Encodable>(fromComponents components: URLComponents, method: HTTPMethod = .get, model: T) throws -> URLRequest {
        return try URLRequest.constructRequest(fromComponents: components, method: method, bodyData: encoder.encode(model))
    }
}
