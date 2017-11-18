//
//  MovieResponse.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MovieResponse: Decodable {
    var page: Int
    var results: [Movie]
    var totalResults: Int
    var totalPages: Int
    var dates: String?
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case dates
    }
}
