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

/// A protocol that defines the interface for HTTP sessions.
/// This abstraction is useful for testing, as it allows the real network session
/// to be replaced with a mock in tests.
///```swift
/// struct MockSession: HTTPSession {
///     func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
///         throw URLError(.notConnectedToInternet)
///     }
/// }
///
/// let mock = HTTPClient(jsonDecoder: JSONDecoder(), session: MockSession())
/// let real = HTTPClient(jsonDecoder: JSONDecoder(), session: URLSession.shared)
///```
public protocol HTTPSession {
    /// Performs the network request asynchronously and returns the data and response.
    /// - Parameter request: The `URLRequest` to be executed.
    /// - Returns: A tuple containing the data and the URL response.
    /// - Throws: An error if the request fails.
    func dataTask(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Extension of URLSession that conforms to the `HTTPSession` protocol.
/// This allows the standard URLSession to be used as part of our abstracted HTTP client.
extension URLSession: HTTPSession {
    /// Implements `dataTask` using async/await to perform the request and return the data and response.
    /// This allows the standard `URLSession` to be used in structured concurrency contexts.
    /// - Parameter request: The `URLRequest` to be executed.
    /// - Returns: A tuple containing the data and the URL response.
    /// - Throws: An error if the request fails.
    public func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request)
    }
}

