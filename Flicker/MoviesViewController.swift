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
    let refresh = UIRefreshControl()
    var posters: [String:UIImage] = [:]
    
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
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        
        refresh.addTarget(self, action: #selector(loadMovies), for: .valueChanged)
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
        if Reachability.isConnectedToNetwork(){
            loadMovies()
        }else{
            let alert = UIAlertController(title: "Error", message: "You are not connected to the Internet!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (alert) in
                SVProgressHUD.show()
                self.loadMovies()
            }))
            self.present(alert, animated: true, completion: nil)
            UIApplication.shared.endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func loadMovies() {
        MovieClient.sharedInstance.getMovies(endpoint: .nowPlaying, page: 1, success: { (movies) in
            self.movies = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                SVProgressHUD.dismiss()
                self.refresh.endRefreshing()
            }
        }) { () in
            if Reachability.isConnectedToNetwork(){
                let alert = UIAlertController(title: "Error", message: "There was an issue loading the movies", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (alert) in
                    SVProgressHUD.show()
                    self.loadMovies()
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Error", message: "You are not connected to the Internet!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (alert) in
                    SVProgressHUD.show()
                    self.loadMovies()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            UIApplication.shared.endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
            self.refresh.endRefreshing()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
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
        var posterUrlSmall = posterBaseSmall + movie.posterPath
        let posterUrlBig = posterBase + movie.posterPath
        if ((posters[posterUrlBig]) != nil) {
            DispatchQueue.main.async {
                if (cell.tag == indexPath.row) {
                    cell.posterView.image = self.posters[posterUrlBig]
                }
            }
        } else {
            downloadImageFromURL(url: posterUrlSmall) { (smallPoster) in
                DispatchQueue.main.async {
                    if (cell.tag == indexPath.row) {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = smallPoster
                    }
                    
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        cell.posterView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        downloadImageFromURL(url: posterUrlBig) { (largePoster) in
                            DispatchQueue.main.async {
                                if (cell.tag == indexPath.row) {
                                    UIView.transition(with: cell.posterView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                                        cell.posterView.image = largePoster
                                    }, completion: nil)
                                    self.posters[posterUrlBig] = largePoster
                                }
                            }
                        }
                    })
                }
            }
        }
        
        //cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView
        
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
