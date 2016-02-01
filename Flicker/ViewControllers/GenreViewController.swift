//
//  GenreViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 1/31/16.
//  Copyright © 2016 Siraj Zaneer. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class GenreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //errorButton.hidden = true
        
        
        loadDataFromNetWork()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! GenreCell
        let genres = movies![indexPath.row]
        if let genre = genres["name"] {
            cell.genreName.text = (genre as! String)
            let id = genres["id"] as? Int
            NSUserDefaults.standardUserDefaults().setInteger(id!, forKey: cell.genreName.text!)
            print(NSUserDefaults.standardUserDefaults().valueForKey(cell.genreName.text!)!)
            
        } else {
            
        }
        //        let posterPath = movie["poster_path"]
        //        if !(posterPath is NSNull){
        //            let baseUrl = "http://image.tmdb.org/t/p/w500"
        //            let imageUrl = NSURL(string: baseUrl + (posterPath as! String))
        //            cell.posterView.setImageWithURL(imageUrl!)
        //        } else {
        //
        //        }
        
        print("row \(indexPath.row)")
        return cell
    }
    func loadDataFromNetWork() {
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let url = NSURL(string:"http://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["genres"] as? [NSDictionary]
                            self.tableView.reloadData()
                            //self.errorButton.hidden = true
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                    }
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.errorButton.hidden = false
                }
        });
        task.resume()
    }
    
    
    @IBAction func errorClick(sender: AnyObject) {
        loadDataFromNetWork()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            print("prepare for segue")
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
        
            let genres = movies![indexPath!.row]
            let id = genres["id"]
            print(id)
            let detailViewController = segue.destinationViewController as! GenreSelectedViewController
            detailViewController.id = id?.stringValue!
        
        
        
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    
    
}