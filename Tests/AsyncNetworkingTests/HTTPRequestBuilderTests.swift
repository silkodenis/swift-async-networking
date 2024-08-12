//
//  HTTPRequestBuilderTests.swift
//  AsyncNetworking
//
//  Created by Denis Silko on 29.04.2024.
//

import XCTest
import AsyncNetworking

final class HTTPRequestBuilderTests: XCTestCase {
    var sut: HTTPRequestBuilder<MockEndpoint>!
    
    override func setUp() {
        super.setUp()
        sut = HTTPRequestBuilder(jsonEncoder: JSONEncoder())
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testRequestCreation() throws {
        let endpoint = MockEndpoint()
        
        do {
            let request = try sut.request(for: endpoint)
            XCTAssertEqual(request.url?.absoluteString, "https://example.com/path?key=value")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMethodAreSetCorrectly() throws {
        let endpoint = MockEndpoint(_method: .delete)
        
        do {
            let request = try sut.request(for: endpoint)
            XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHeadersAreSetCorrectly() throws {
        let headers = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
        ]
        let endpoint = MockEndpoint(_headers: headers)
        
        do {
            let request = try sut.request(for: endpoint)
            headers.forEach { key, value in
                XCTAssertEqual(request.allHTTPHeaderFields?[key], value, "Header \(key) was not set correctly")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMultipleQueryParametersAreAddedCorrectly() throws {
        let parameters = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
        ]
        let endpoint = MockEndpoint(_parameters: parameters)
        
        do {
            let request = try sut.request(for: endpoint)
            let urlString = request.url?.absoluteString ?? ""
            parameters.forEach { key, value in
                XCTAssertTrue(urlString.contains("\(key)=\(value)"), 
                              "Query parameter \(key)=\(value) was not added correctly")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCachePolicy() throws {
        let endpoint = MockEndpoint()
        
        do {
            let request = try sut.request(for: endpoint)
            XCTAssertEqual(request.cachePolicy, .useProtocolCachePolicy, 
                           "Expected cache policy to be .useProtocolCachePolicy")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRequestBodyEncoding() throws {
        struct MockData: Codable {
            let name: String
        }
        
        let endpoint = MockEndpoint(_method: .post)
        let data = MockData(name: "Test")
        
        do {
            let request = try sut.request(for: endpoint, with: data)
            
            guard let bodyData = request.httpBody else {
                XCTFail("Body data is nil")
                return
            }
            
            let decodedData = try JSONDecoder().decode(MockData.self, from: bodyData)
            XCTAssertEqual(decodedData.name, "Test", "Expected body data to contain correct 'name' value")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testEncodingErrorReturnsFailure() throws {
        struct UnencodableMockData: Codable {
            let data: Data

            init() {
                self.data = Data()
            }

            func encode(to encoder: Encoder) throws {
                throw EncodingError.invalidValue(data, EncodingError.Context(codingPath: [], 
                                                                             debugDescription: "Cannot encode Data directly"))
            }
        }

        let endpoint = MockEndpoint(_method: .post)
        let data = UnencodableMockData()

        do {
            _ = try sut.request(for: endpoint, with: data)
            XCTFail("Expected failure, but got success")
        } catch {
            if let _ = error as? EncodingError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected EncodingError, but got \(error)")
            }
        }
    }
}

//MARK: - MockEndpoint

extension HTTPRequestBuilderTests {
    
    struct MockEndpoint: HTTPEndpoint {
        var _method: HTTPMethod = .get
        var _parameters: [String : Any]? = ["key": "value"]
        var _headers: [String : String]? = ["Content-Type": "application/json"]
        
        // MARK: - HTTPEndpoint
        var baseURL: URL { return URL(string: "https://example.com")! }
        var path: String { return "/path" }
        var method: HTTPMethod { return _method }
        var headers: [String : String]? { return _headers }
        var parameters: [String : Any]? { return _parameters }
    }
    
}
