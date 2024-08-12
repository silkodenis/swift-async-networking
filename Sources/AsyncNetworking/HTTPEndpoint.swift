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

/// Represents the HTTP methods available for networking calls.
/// These methods correspond to the various actions you can perform on a resource.
public enum HTTPMethod: String {
    /// Represents an HTTP GET request, used to retrieve data.
    case get = "GET"
    
    /// Represents an HTTP PUT request, used to update a resource.
    case put = "PUT"
    
    /// Represents an HTTP POST request, used to create a resource.
    case post = "POST"
    
    /// Represents an HTTP HEAD request, used to fetch headers.
    case head = "HEAD"
    
    /// Represents an HTTP DELETE request, used to delete a resource.
    case delete = "DELETE"
}

/// Defines the requirements for a type to be considered an HTTP endpoint.
/// An endpoint is typically a specific location on a server where certain data can be accessed.
public protocol HTTPEndpoint {
    /// The base URL of the API endpoint.
    var baseURL: URL { get }
    
    /// The path component of the API endpoint. This path is appended to the `baseURL`.
    var path: String { get }
    
    /// The HTTP method used for the API call.
    var method: HTTPMethod { get }
    
    /// Optional dictionary of headers to include in the API request.
    var headers: [String: String]? { get }
    
    /// Optional dictionary of parameters to be included in the request.
    /// These parameters may be used in the query string for GET requests or in the request body for POST requests.
    var parameters: [String: Any]? { get }
}
