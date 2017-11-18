//
//  MovieClient.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/17/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MovieClient {
    let sharedInstance = MovieClient()
    
    func getMovies(endpoint: MovieListEndpoints, success: ([Movie]) -> (), failure: (Error) -> ()) {
        endpoint.rawValue
    }
}

enum MovieListEndpoints: String {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming
}
