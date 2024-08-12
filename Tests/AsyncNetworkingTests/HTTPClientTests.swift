//
//  HTTPClient.swift
//  AsyncNetworking
//
//  Created by Denis Silko on 30.04.2024.
//

import XCTest
import AsyncNetworking

final class HTTPClientTests: XCTestCase {
    
    func testInvalidHTTPResponseStatus() async throws {
        struct MockSession: HTTPSession {
            func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
                let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil,
                                               headerFields: ["Content-Type": "application/json"])!
                return (Data(), response)
            }
        }

        let sut = HTTPClient(jsonDecoder: JSONDecoder(), session: MockSession())
        let requestURL = URL(string: "https://example.com")!
        let request = URLRequest(url: requestURL)

        do {
            _ = try await sut.execute(request) as Data
            XCTFail("Expected failure due to invalid response status, but got success")
        } catch {
            if let httpClientError = error as? HTTPClientError,
               case .invalidResponse(let details) = httpClientError {
                XCTAssertEqual(details.statusCode, 404, "Expected status code 404")
                XCTAssertEqual(details.url, requestURL, "Expected URL to match request URL")
                XCTAssertNotNil(details.description, "Expected description to be non-nil")
                XCTAssertEqual(details.headers?["Content-Type"], "application/json", "Expected correct content type header")
            } else {
                XCTFail("Expected HTTPClientError.invalidResponse with status code 404")
            }
        }
    }
    
    func testSuccessfulDataFetch() async throws {
        struct MockResponse: Codable, Equatable {
            let id: Int
            let name: String
        }
        
        struct MockSession: HTTPSession {
            let responseData: Data
            
            func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (responseData, response)
            }
        }
        
        let mockResponse = MockResponse(id: 1, name: "Test")
        let mockSession = MockSession(responseData: try JSONEncoder().encode(mockResponse))
        let sut = HTTPClient(jsonDecoder: JSONDecoder(), session: mockSession)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        do {
            let decodedData: MockResponse = try await sut.execute(request)
            XCTAssertEqual(decodedData, mockResponse)
        } catch {
            XCTFail("Request failed when success was expected: \(error)")
        }
    }
    
    func testNetworkErrorHandling() async throws {
        struct MockSession: HTTPSession {
            func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
                throw URLError(.notConnectedToInternet)
            }
        }
        
        let sut = HTTPClient(jsonDecoder: JSONDecoder(), session: MockSession())
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        do {
            _ = try await sut.execute(request) as String
            XCTFail("Expected failure due to network error, but received data")
        } catch {
            if let httpClientError = error as? HTTPClientError,
               case .networkError(let underlyingError) = httpClientError,
               let urlError = underlyingError as? URLError {
                XCTAssertEqual(urlError.code, .notConnectedToInternet)
            } else {
                XCTFail("Expected HTTPClientError.networkError with URLError.notConnectedToInternet")
            }
        }
    }
    
    func testInvalidJSONDecoding() async throws {
        struct MockSession: HTTPSession {
            func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                let invalidJSONData = "invalid-json".data(using: .utf8)!
                return (invalidJSONData, response)
            }
        }

        let sut = HTTPClient(jsonDecoder: JSONDecoder(), session: MockSession())
        let request = URLRequest(url: URL(string: "https://example.com")!)

        do {
            _ = try await sut.execute(request) as String
            XCTFail("Expected failure due to invalid JSON, but got success")
        } catch {
            if let httpClientError = error as? HTTPClientError,
               case .decodingError(let error) = httpClientError {
                XCTAssertTrue(error is DecodingError, "Expected DecodingError, but got \(type(of: error))")
            } else {
                XCTFail("Expected HTTPClientError.decodingError, but got a different error: \(error)")
            }
        }
    }
}
