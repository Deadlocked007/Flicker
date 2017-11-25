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
    var endpoint = MovieListEndpoints.nowPlaying
    var page = 1
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.delegate = self
        
        switch tabBarController!.selectedIndex {
        case 0:
            endpoint = .nowPlaying
            tabBarController?.tabBar.items![0].image = UIImage(named: "now_playing_tabbar_item")
            tabBarController?.tabBar.items![0].title = "Now Playing"
            navigationController?.navigationBar.topItem?.title  = "Now Playing"
        case 1:
            endpoint = .topRated
            tabBarController?.tabBar.items![1].image = UIImage(named: "toprated")
            tabBarController?.tabBar.items![1].title = "Top Rated"
            navigationController?.navigationBar.topItem?.title = "Top Rated"
        case 2:
            endpoint = .popular
            tabBarController?.tabBar.items![2].image = UIImage(named: "reel_tabbar_icon")
            tabBarController?.tabBar.items![2].title = "Popular"
            navigationController?.navigationBar.topItem?.title = "Popular"
        case 3:
            endpoint = .upcoming
            tabBarController?.tabBar.items![3].image = UIImage(named: "ticket_tabbar_icon")
            tabBarController?.tabBar.items![3].title = "Upcoming"
            navigationController?.navigationBar.topItem?.title = "Upcoming"
        default:
            break
        }
        view.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch tabBarController!.selectedIndex {
        case 0:
            endpoint = .nowPlaying
            tabBarController?.tabBar.items![0].image = UIImage(named: "now_playing_tabbar_item")
            tabBarController?.tabBar.items![0].title = "Now Playing"
            navigationController?.navigationBar.topItem?.title  = "Now Playing"
        case 1:
            endpoint = .topRated
            tabBarController?.tabBar.items![1].image = UIImage(named: "toprated")
            tabBarController?.tabBar.items![1].title = "Top Rated"
            navigationController?.navigationBar.topItem?.title = "Top Rated"
        case 2:
            endpoint = .popular
            tabBarController?.tabBar.items![2].image = UIImage(named: "reel_tabbar_icon")
            tabBarController?.tabBar.items![2].title = "Popular"
            navigationController?.navigationBar.topItem?.title = "Popular"
        case 3:
            endpoint = .upcoming
            tabBarController?.tabBar.items![3].image = UIImage(named: "ticket_tabbar_icon")
            tabBarController?.tabBar.items![3].title = "Upcoming"
            navigationController?.navigationBar.topItem?.title = "Upcoming"
        default:
            break
        }
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Movies"
        searchController.obscuresBackgroundDuringPresentation = false
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175
        
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        refresh.addTarget(self, action: #selector(loadMovies), for: .valueChanged)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
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
        isMoreDataLoading = true
        if refresh.isRefreshing {
            page = 1
        }
        
        MovieClient.sharedInstance.getMovies(endpoint: endpoint, page: page, success: { (movies) in
            self.movies = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                SVProgressHUD.dismiss()
                self.refresh.endRefreshing()
                self.loadingMoreView!.stopAnimating()
                self.isMoreDataLoading = false
            }
        }) { () in
            if Reachability.isConnectedToNetwork(){
                let alert = UIAlertController(title: "Error", message: "There was an issue loading the movies", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (alert) in
                    SVProgressHUD.show()
                    self.loadingMoreView!.stopAnimating()
                    self.isMoreDataLoading = false
                    self.loadMovies()
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Error", message: "You are not connected to the Internet!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (alert) in
                    self.loadingMoreView!.stopAnimating()
                    self.isMoreDataLoading = false
                    SVProgressHUD.show()
                    self.loadMovies()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            UIApplication.shared.endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
            self.refresh.endRefreshing()
            self.loadingMoreView!.stopAnimating()
            self.isMoreDataLoading = false
        }
    }
    
    @IBAction func onSearch(_ sender: Any) {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                page += 1
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMovies()
            }
        }
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
        cell.titleLabel.textColor = .black
        cell.overviewLabel.textColor = .black
        cell.titleLabel.sizeToFit()
        if let posterPath = movie.posterPath {
            let posterUrlSmall = posterBaseSmall + posterPath
            let posterUrlBig = posterBase + posterPath
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
        }
        
        
        //cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "detailSegue":
            let cell = sender as! MovieCell
            let detailSegue = segue as! DetailSegue
            let indexPath = tableView.indexPath(for: cell)!
            let destination = segue.destination as! DetailViewController
            detailSegue.index = indexPath.row
            if isFiltering() {
                destination.movie = filteredMovies[indexPath.row]
            } else {
                destination.movie = movies[indexPath.row]
            }
        default:
            break
        }
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
            let doesCategoryMatch = (scope == "All")
            
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

extension MoviesCollectionViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController == self.navigationController {
            performSegue(withIdentifier: "fadeSegue", sender: nil)
        }
    }
}
