//
//  MoviesEndpoint.swift
//  MoviesAPI
//
//  Created by Denis Silko on 12.04.2024.
//

import Foundation
import AsyncNetworking

enum MoviesEndpoint {
    case authentication
    case validation
    case session
    case guestSession
    case deleteSession
    case configuration
    case trending(TimeWindow)
    case movieDetail(id: Int)

    private static let apiKey = "7991ddf0e789dc96d90ed191a4fda7ff"
    private static let baseURL = URL(string: "https://api.themoviedb.org/3")!
}

extension MoviesEndpoint: HTTPEndpoint {
    var baseURL: URL {
        return Self.baseURL
    }
    
    var path: String {
        switch self {
        case .authentication: return "authentication/token/new"
        case .validation: return "authentication/token/validate_with_login"
        case .session: return "authentication/session/new"
        case .guestSession: return "authentication/guest_session/new"
        case .deleteSession: return "authentication/session"
        case .configuration: return "configuration"
        case .trending(let timeWindow): return "trending/movie/\(timeWindow.rawValue)"
        case .movieDetail(let id): return "movie/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .validation, .session:
            return .post
        case .deleteSession:
            return .delete
        default:
            return .get
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Accept": "application/json"]
        switch self {
        case .validation, .session, .deleteSession:
            headers["Content-Type"] = "application/json"
        default: break
        }
        return headers
    }
    
    var parameters: [String: Any]? {
        return ["api_key": Self.apiKey]
    }
}

// MARK: - Inner Types

extension MoviesEndpoint {
    enum TimeWindow: String {
        case day
        case week
    }
}
