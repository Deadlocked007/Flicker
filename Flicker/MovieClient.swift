//
//  MovieClient.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/17/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MovieClient {
    
    static let sharedInstance = MovieClient()
    let baseURL = "https://api.themoviedb.org/3/movie/"
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    func getMovies(endpoint: MovieListEndpoints, page: Int, success: @escaping ([Movie]) -> (), failure: @escaping () -> ()) {
        let urlString = baseURL + endpoint.rawValue
        var urlComp = URLComponents(string: urlString)
        var qItems = [URLQueryItem(name: "api_key", value: apiKey)]
        qItems.append(URLQueryItem(name: "page", value: String(page)))
        urlComp?.queryItems = qItems
        let url = urlComp!.url!
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                failure()
            } else if let data = data {
                let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                let results = jsonData["results"] as! [Dictionary<String, Any>]
                var movies = [Movie]()
                for result in results {
                    movies.append(Movie(movieInfo: result))
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
