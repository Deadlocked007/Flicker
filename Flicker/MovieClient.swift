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
    let apiKey = "70ae7d09462b8d19be01b5e2f0d2e752"
    
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
                let totalPages = jsonData["total_pages"] as! Int
                success(movies)
            }
        }
        task.resume()
    }
    
    func getVideo(id: Int, width: Int, height: Int, success: @escaping (String) -> (), failure: @escaping () -> ()) {
        let urlString = "\(baseURL)\(id)/videos"
        var urlComp = URLComponents(string: urlString)
        let qItems = [URLQueryItem(name: "api_key", value: apiKey)]
        urlComp?.queryItems = qItems
        let url = urlComp!.url!
        let urlSession = URLSession(configuration: .default)
        
        let task = urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                failure()
            } else if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, Any> {
                    if let videos = responseDictionary["results"] as? [Dictionary<String, Any>], videos.count > 0 {
                        let video = videos[0]
                        let key = video["key"] as! String
                        let htm = "<!DOCTYPE HTML> <html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:og=\"http://opengraphprotocol.org/schema/\" xmlns:fb=\"http://www.facebook.com/2008/fbml\"> <head></head> <body style=\"margin:0 0 0 0; padding:0 0 0 0;\"> <iframe width=\"\(width)\" height=\"\(height)\" src=\"http://www.youtube.com/embed/\(key)\" frameborder=\"0\"></iframe> </body> </html> "
                        print(htm)
                        success(htm)
                    } else {
                        failure()
                    }
                }
            }
        })
        task.resume()
    }
    
    func getRelatedMovies(id: Int, success: @escaping ([Movie]) -> (), failure: @escaping () -> ()) {
        let urlString = "\(baseURL)\(id)/similar"
        var urlComp = URLComponents(string: urlString)
        let qItems = [URLQueryItem(name: "api_key", value: apiKey)]
        urlComp?.queryItems = qItems
        let url = urlComp!.url!
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                failure()
            } else if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, Any> {
                    let related = responseDictionary["results"] as! [Dictionary<String, Any>]
                    var movies = [Movie]()
                    for result in related {
                        movies.append(Movie(movieInfo: result))
                    }
                    success(movies)
                }
            }
        })
        task.resume()
    }
}

enum MovieListEndpoints: String {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming
}
