//
//  DefaultMoviesAPI.swift
//  MoviesAPI
//
//  Created by Denis Silko on 09.04.2024.
//  Copyright © 2024 Denis Silko. All rights reserved.
//

import Foundation
import AsyncNetworking

protocol MoviesAPI {
    func authentication() async throws -> TokenDTO
    func validation(username: String, password: String, token: String) async throws -> TokenDTO
    func session(with token: String) async throws -> SessionDTO
    func guestSession() async throws -> SessionDTO
    func deleteSession(with id: String) async throws -> SessionDTO
    func configuration() async throws -> ConfigurationDTO
    func trending() async throws -> PageDTO<MovieDTO>
    func movieDetail(id: Int) async throws -> MovieDetailDTO
}

class DefaultMoviesAPI: MoviesAPI {
    typealias Endpoint = MoviesEndpoint
    
    private let client: HTTPClient
    private let builder: HTTPRequestBuilder<Endpoint>
    
    init(httpClient: HTTPClient, requestBuilder: HTTPRequestBuilder<Endpoint>) {
        self.client = httpClient
        self.builder = requestBuilder
    }
    
    func authentication() async throws -> TokenDTO {
        let request = try builder.request(for: .authentication)
        return try await client.execute(request)
    }
    
    func validation(username: String, password: String, token: String) async throws -> TokenDTO {
        let data = Login(username: username, password: password, request_token: token)
        let request = try builder.request(for: .validation, with: data)
        return try await client.execute(request)
    }
    
    func session(with token: String) async throws -> SessionDTO {
        let data = Token(request_token: token)
        let request = try builder.request(for: .session, with: data)
        return try await client.execute(request)
    }
    
    func guestSession() async throws -> SessionDTO {
        let request = try builder.request(for: .guestSession)
        return try await client.execute(request)
    }
    
    func deleteSession(with id: String) async throws -> SessionDTO {
        let data = Session(session_id: id)
        let request = try builder.request(for: .deleteSession, with: data)
        return try await client.execute(request)
    }
    
    func configuration() async throws -> ConfigurationDTO {
        let request = try builder.request(for: .configuration)
        return try await client.execute(request)
    }
    
    func trending() async throws -> PageDTO<MovieDTO> {
        let request = try builder.request(for: .trending(.week))
        return try await client.execute(request)
    }
    
    func movieDetail(id: Int) async throws -> MovieDetailDTO {
        let request = try builder.request(for: .movieDetail(id: id))
        return try await client.execute(request)
    }
}

// MARK: - fileprivate inner types

fileprivate extension DefaultMoviesAPI {
    struct Login: Codable {
        let username: String
        let password: String
        let request_token: String
    }
    
    struct Token: Codable {
        let request_token: String
    }
    
    struct Session: Codable {
        let session_id: String
    }
}
