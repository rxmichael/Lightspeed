//
//  SWAPIService.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/18/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation

class SWAPIService: CodableNetworkServiceType {
    var session: URLSession
    var decoder: JSONDecoder { return SWAPI.decoder }
    var encoder: JSONEncoder { return SWAPI.encoder }
    
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        return session.dataTaskPublisher(for: request)
    }
    
    var currentEndpoint: String {
        Current.endpoint
    }
    
    init(_ session: URLSession = SWAPI.session) {
        self.session = session
    }
}

enum SWAPI {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func baseURL(endpoint: String) throws -> URL {
        return try URL(string: endpoint)
            .orThrow(NetworkError.failedToConstructRequest)
    }
    
    static func baseURLComponents(endpoint: String) throws -> URLComponents {
        return try URLComponents(url: baseURL(endpoint: endpoint), resolvingAgainstBaseURL: false)
            .orThrow(NetworkError.failedToConstructRequest)
    }
    
    static let session: URLSession = {
        let configuration: URLSessionConfiguration = .default
        
        // Keep default additional headers but also add our own
        configuration.httpAdditionalHeaders =
            (configuration.httpAdditionalHeaders ?? [:])
            .merging(defaultHTTPHeaders(), uniquingKeysWith: { _, new in new })
        
        return URLSession(configuration: configuration)
    }()
    
    /// Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
    private static func defaultHTTPHeaders(forBundle bundle: Bundle = Bundle.main) -> [String: String] {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = "en"
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.0 (com.acme.my-app; build:1; iOS 10.0.0)`
        let userAgent: String = {
            guard let info = bundle.infoDictionary else { return "Lightspeed-Demo" }
            
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            
            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                
                let osName: String = {
                    #if os(iOS)
                        return "iOS"
                    #elseif os(watchOS)
                        return "watchOS"
                    #elseif os(tvOS)
                        return "tvOS"
                    #elseif os(macOS)
                        return "OS X"
                    #elseif os(Linux)
                        return "Linux"
                    #else
                        return "Unknown"
                    #endif
                }()
                
                return "\(osName) \(versionString)"
            }()
            
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent,
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
    }
}


