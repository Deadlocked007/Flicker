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
    let baseURL = "https://api.themoviedb.org/3/movie/"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    func getMovies(endpoint: MovieListEndpoints, page: Int, success: @escaping ([Movie]) -> (), failure: @escaping (Error) -> ()) {
        let urlString = baseURL + endpoint.rawValue
        var urlComp = URLComponents(string: urlString)
        var qItems = [URLQueryItem(name: "api_key", value: apiKey)]
        qItems.append(URLQueryItem(name: "page", value: String(page)))
        urlComp?.queryItems = qItems
        let url = urlComp!.url!
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                failure(error)
            } else if let data = data {
                let decoder = JSONDecoder()
                guard let movies = try? decoder.decode([Movie].self, from: data) else {
                    return
                }
                success(movies)
            }
        }
        task.resume()
    }
}

enum MovieListEndpoints: String {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming
}
