//
//  Movie.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/17/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class Movie: Decodable {
    var votes: Int
    var id: Int
    var video: Bool
    var voteAverage: Double
    var title: String
    var popularity: Double
    var posterPath: String
    var originalLanguage: String
    var originalTitle: String
    var genreIds: [Int]
    var backdropPath: String
    var adult: Bool
    var overview: String
    //var releaseDate: Date
    
    init(movieInfo: Dictionary<String, Any>) {
        votes = movieInfo["vote_count"] as! Int
        id = movieInfo["id"] as! Int
        video = movieInfo["video"] as! Bool
        voteAverage = movieInfo["vote_average"] as! Double
        title = movieInfo["title"] as! String
        popularity = movieInfo["popularity"] as! Double
        posterPath = movieInfo["poster_path"] as! String
        originalLanguage = movieInfo["original_language"] as! String
        originalTitle = movieInfo["original_title"] as! String
        genreIds = movieInfo["genre_ids"] as! [Int]
        backdropPath = movieInfo["backdrop_path"] as! String
        adult = movieInfo["adult"] as! Bool
        overview = movieInfo["overview"] as! String
        //releaseDate = movieInfo["releasedate"] as! Date
    }
//    enum CodingKeys: String, CodingKey {
//        case votes = "vote_count"
//        case id
//        case video
//        case voteAverage = "vote_average"
//        case title
//        case popularity
//        case posterPath = "poster_path"
//        case originalLanguage = "original_language"
//        case originalTitle = "original_title"
//        case genreIds = "genre_ids"
//        case backdropPath = "backdrop_path"
//        case adult
//        case overview
//        case releaseDate
//    }
}

/*
vote_count    3739
id    346364
video    false
vote_average    7.3
title    "It"
popularity    994.84701
poster_path    "/9E2y5Q7WlCVNEhP5GiVTjhEhx1o.jpg"
original_language    "en"
original_title    "It"
genre_ids
0    14
1    27
2    53
backdrop_path    "/tcheoA2nPATCm2vvXw2hVQoaEFD.jpg"
adult    false
overview    "In a small town in Maine, seven children known as The Losers Club come face to face with life problems, bullies and a monster that takes the shape of a clown called Pennywise."
release_date    "2017-09-05"
*/
