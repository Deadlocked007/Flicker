//
//  NowPlayingViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 1/30/16.
//  Copyright © 2016 Siraj Zaneer. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class NowPlayingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var errorButton: UIButton!
    var movies: [NSDictionary]?
    
    var filteredData: [NSDictionary]?
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        loadDataFromNetwork()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadDataFromNetwork() {
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            
                            self.filteredData = responseDictionary["results"] as? [NSDictionary]
                            self.errorButton.hidden = true
                            self.collectionView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)

                            
                    }
                } else {
                    self.errorButton.hidden = false
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        })
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredData![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        cell.posterView.setImageWithURLRequest(
            imageUrl,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        }
        
        print("row \(indexPath.row)")
        return cell

        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.filteredData = responseDictionary["results"] as? [NSDictionary]
                            
                            self.collectionView.reloadData()
                            
                            refreshControl.endRefreshing()
                            
                            
                    }
                }
        })
        task.resume()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("search")
        if searchText.isEmpty {
            filteredData = movies
        } else {
            filteredData = searchText.isEmpty ? movies : movies!.filter({(movieName: NSDictionary) -> Bool in
                if let title = movieName["title"] as? String {
                    return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                }
                return false
            })
        }
        collectionView.reloadData()
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                filteredData = movies
            } else {
                filteredData = searchText.isEmpty ? movies : movies!.filter({(movieName: NSDictionary) -> Bool in
                    if let title = movieName["title"] as? String {
                        return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                    }
                    return false
                })
            }
        }
        collectionView.reloadData()
    }
    @IBAction func error(sender: AnyObject) {
        loadDataFromNetwork()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepare for segue")
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movies = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
