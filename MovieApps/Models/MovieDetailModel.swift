//
//  MovieDetailModel.swift
//  MovieApps
//
//  Created by Faza Azizi on 18/03/25.
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let genres: [Genre]
    let imdbId: String?
    let credits: Credits?
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres
        case posterPath = "poster_path"
        case imdbId = "imdb_id"
        case credits
        case voteAverage = "vote_average"
    }
    
    static var empty: MovieDetail {
        return MovieDetail(
            id: 0,
            title: "",
            overview: "",
            posterPath: nil,
            genres: [],
            imdbId: nil,
            credits: nil,
            voteAverage: 0
        )
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct Credits: Codable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Codable {
    let id: Int
    let name: String
    let character: String
}

struct Crew: Codable {
    let id: Int
    let name: String
    let job: String
}
