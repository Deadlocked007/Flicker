//
//  MoviesCollectionViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/23/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SVProgressHUD

class MoviesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var movies = [Movie]()
    var filteredMovies = [Movie]()
    let searchController = UISearchController(searchResultsController: nil)
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Movies"
        searchController.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refresh
        } else {
            collectionView?.addSubview(refresh)
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
                self.collectionView?.reloadData()
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMovies.count
        }
        
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2.0, height: view.frame.width / 2.0 * 1.5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionCell
        
        var movie: Movie!
        cell.tag = indexPath.row
        cell.posterView.image = nil
        
        if isFiltering() {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        let posterUrlSmall = posterBaseSmall + movie.posterPath
        let posterUrlBig = posterBase + movie.posterPath
        let posterUrlSmallRequest = URLRequest(url: URL(string: posterUrlSmall)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        let posterUrlBigRequest = URLRequest(url: URL(string: posterUrlBig)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        if let cachedImage = URLCache.shared.cachedResponse(for: posterUrlBigRequest) {
            DispatchQueue.main.async {
                if (cell.tag == indexPath.row) {
                    cell.posterView.image = UIImage(data: cachedImage.data)
                }
            }
        } else {
            downloadImageFromURL(urlRequest: posterUrlSmallRequest) { (smallPoster) in
                DispatchQueue.main.async {
                    if (cell.tag == indexPath.row) {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = smallPoster
                    }
                    
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        cell.posterView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        downloadImageFromURL(urlRequest: posterUrlBigRequest) { (largePoster) in
                            DispatchQueue.main.async {
                                if (cell.tag == indexPath.row) {
                                    UIView.transition(with: cell.posterView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                                        cell.posterView.image = largePoster
                                    }, completion: nil)
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

extension MoviesCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        searchEvents(searchController.searchBar.text!, scope: "All")
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func searchEvents(_ searchText: String, scope: String = "All") {
        filteredMovies = movies.filter({ (movie) -> Bool in
            let doesCategoryMatch = (scope == "All")
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && (movie.title.lowercased().contains(searchText.lowercased()) || movie.overview.lowercased().contains(searchText.lowercased()))
            }
        })
        self.collectionView?.reloadData()
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