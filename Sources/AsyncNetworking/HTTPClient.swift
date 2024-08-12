/*
 * Copyright (c) [2024] [Denis Silko]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     https://github.com/silkodenis/swift-async-networking
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// Represents various errors that can occur during HTTP networking.
public enum HTTPClientError: Error {
    /// Indicates that the HTTP response was invalid.
    /// Contains details about the response.
    case invalidResponse(Details)
    
    /// Indicates an error occurred while decoding the response data.
    case decodingError(Error)
    
    /// Indicates a network error occurred during the HTTP request.
    case networkError(Error)
    
    /// Encapsulates details of an invalid HTTP response.
    public struct Details {
        /// The HTTP status code of the response.
        public let statusCode: Int
        
        /// The URL of the request that generated the response.
        public let url: URL?
        
        /// A human-readable description of the response.
        public let description: String?
        
        /// The headers returned with the response.
        public let headers: [String: String]?
    }
}

/// A client for executing HTTP requests and decoding responses.
public final class HTTPClient {
    /// A JSON decoder to decode the response data.
    private let decoder: JSONDecoder
    
    /// A session conforming to `HTTPSession` for handling requests.
    private let session: HTTPSession
    
    /// Initializes a new HTTPClient with the given JSON decoder and session.
    /// - Parameters:
    ///   - jsonDecoder: A `JSONDecoder` to use for decoding the response data.
    ///   - session: An `HTTPSession` for sending requests and receiving responses.
    public init(jsonDecoder: JSONDecoder, session: HTTPSession) {
        self.decoder = jsonDecoder
        self.session = session
    }
    
    /// Executes a request and decodes the response.
    /// - Parameter request: The `URLRequest` to execute.
    /// - Returns: The decoded response.
    /// - Throws: An error if the request or decoding fails.
    public func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.dataTask(for: request)
            try Self.validateResponse(response, for: request)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw Self.mapError(error)
        }
    }
}

// MARK: - Error handling

fileprivate extension HTTPClient {
    /// Validates the HTTP response to ensure it is acceptable.
    /// - Parameters:
    ///   - response: The response to validate.
    ///   - request: The original request.
    /// - Throws: `HTTPClientError.invalidResponse` if the response is unacceptable.
    private static func validateResponse(_ response: URLResponse, for request: URLRequest) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse(HTTPClientError.Details(
                statusCode: -1,
                url: request.url,
                description: "Invalid response type",
                headers: nil
            ))
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw HTTPClientError.invalidResponse(HTTPClientError.Details(
                statusCode: httpResponse.statusCode,
                url: request.url,
                description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                headers: httpResponse.allHeaderFields as? [String: String]
            ))
        }
    }

    /// Maps any error to an `HTTPClientError`.
    /// - Parameter error: The error to map.
    /// - Returns: An appropriate `HTTPClientError` based on the error type.
    private static func mapError(_ error: Error) -> HTTPClientError {
        switch error {
        case let httpClientError as HTTPClientError:
            return httpClientError
        case let decodingError as DecodingError:
            return HTTPClientError.decodingError(decodingError)
        default:
            return HTTPClientError.networkError(error)
        }
    }
}

