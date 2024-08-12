//
//  MoviesDTOs.swift
//  MoviesAPI
//
//  Created by Denis Silko on 12.04.2024.
//

import Foundation

struct TokenDTO: Codable {
    let success: Bool
    let expires_at: String
    let request_token: String
}

struct SessionDTO: Codable {
    let success: Bool
    let session_id: String?
    let guest_session_id: String?
    let expires_at: String?
}

struct ConfigurationDTO: Codable {
    let images: ImagesDTO

    struct ImagesDTO: Codable {
        let secure_base_url: URL
        let poster_sizes: [PosterSizeDTO]
        
        enum PosterSizeDTO: String, Codable {
            case w92
            case w154
            case w185
            case w342
            case w500
            case w780
            case original
        }
    }
}

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let poster_path: String
}

struct MovieDetailDTO: Codable {
    let id: Int
    let title: String
    let overview: String?
    let poster_path: String
    let vote_average: Double?
    let genres: [GenreDTO]
    let release_date: String?
    let runtime: Int?
    let spoken_languages: [LanguageDTO]
    
    struct GenreDTO: Codable {
        let id: Int
        let name: String
    }
    
    struct LanguageDTO: Codable {
        let name: String
    }
}

struct PageDTO<T: Codable>: Codable {
    let page: Int?
    let total_results: Int?
    let total_pages: Int?
    let results: [T]
}
