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

/// A class responsible for constructing HTTP requests based on specified endpoints and parameters.
/// This class provides a declarative way to build and configure network requests.
public final class HTTPRequestBuilder<T: HTTPEndpoint> {
    /// JSON encoder to encode request data.
    private let jsonEncoder: JSONEncoder
    
    /// Initializes a new HTTPRequestBuilder with the given JSON encoder.
    /// - Parameter jsonEncoder: A `JSONEncoder` used to encode the data to be sent in network requests.
    public init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }

    /// Constructs a URLRequest with provided endpoint and data.
    /// - Parameters:
    ///   - endpoint: The endpoint containing all necessary information to build the URL.
    ///   - data: Optional Codable data to be included as the HTTP body.
    /// - Throws: An error if the URL cannot be constructed or the data cannot be encoded.
    /// - Returns: A configured URLRequest ready to be executed.
    public func request(for endpoint: T, with data: Codable? = nil) throws -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)?
                .addingQueryItems(endpoint.parameters), let finalURL = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        if let data = data {
            request.httpBody = try jsonEncoder.encode(data)
        }

        return request
    }
}

// MARK: - fileprivate

/// Extension to handle the addition of query items to URLComponents.
fileprivate extension URLComponents {
    /// Adds query items to the URLComponents instance from a dictionary of parameters.
    /// - Parameter queryItems: A dictionary containing the query parameters.
    /// - Returns: A modified URLComponents instance including the new query items.
    func addingQueryItems(_ queryItems: [String: Any]?) -> URLComponents {
        var copy = self
        copy.queryItems = queryItems?.compactMap { key, value in
            if let value = value as? CustomStringConvertible {
                return URLQueryItem(name: key, value: value.description)
            }
            return nil
        }
        return copy
    }
}
