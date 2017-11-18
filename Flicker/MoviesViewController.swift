//
//  MoviesViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/17/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MoviesViewController: UITableViewController {

    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        loadMovies()
    }
    
    func loadMovies() {
        MovieClient.sharedInstance.getMovies(endpoint: .nowPlaying, page: 1, success: { (movies) in
            self.movies = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }) { () in
            print("error")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        var movie: Movie!
        cell.tag = indexPath.row
        cell.posterView.image = nil
        movie = movies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        let posterUrl = posterBase + movie.posterPath
        downloadImageFromURL(url: posterUrl) { (posterImage) in
            DispatchQueue.main.async {
                if (cell.tag == indexPath.row) {
                    cell.posterView.image = posterImage
                }
            }
        }
        return cell
    }

}
