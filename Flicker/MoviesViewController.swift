//
//  MoviesViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/17/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SVProgressHUD

class MoviesViewController: UITableViewController {

    var movies = [Movie]()
    var filteredMovies = [Movie]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Hackathons"
        searchController.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.target(forAction: #selector(loadMovies), withSender: nil)
        tableView.insertSubview(refreshControl!, at: 0)
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
        loadMovies()
    }
    
    @objc func loadMovies() {
        MovieClient.sharedInstance.getMovies(endpoint: .nowPlaying, page: 1, success: { (movies) in
            self.movies = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                SVProgressHUD.dismiss()
                self.refreshControl?.endRefreshing()
            }
        }) { () in
            print("error")
            UIApplication.shared.endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func onSearch(_ sender: Any) {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMovies.count
        }
        
        return movies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        var movie: Movie!
        cell.tag = indexPath.row
        cell.posterView.image = nil
    
        
        if isFiltering() {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        cell.titleLabel.sizeToFit()
        cell.overviewLabel.sizeToFit()
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

extension MoviesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        searchEvents(searchController.searchBar.text!, scope: "All")
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func searchEvents(_ searchText: String, scope: String = "All") {
        filteredMovies = movies.filter({ (movie) -> Bool in
            var doesCategoryMatch = (scope == "All")
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && (movie.title.lowercased().contains(searchText.lowercased()) || movie.overview.lowercased().contains(searchText.lowercased()))
            }
        })
        self.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchEvents(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
