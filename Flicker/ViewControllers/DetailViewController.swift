//
//  DetailViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 1/30/16.
//  Copyright © 2016 Siraj Zaneer. All rights reserved.
//
import UIKit
import AFNetworking
import MBProgressHUD

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var videos: [NSDictionary]?
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: NSDictionary!
    
    var related: [NSDictionary]?

    @IBOutlet weak var relatedRight: UIView!
    @IBOutlet weak var relatedLeft: UIView!
    @IBOutlet weak var relatedMLabel: UILabel!
    @IBOutlet weak var doge3: UIImageView!
    @IBOutlet weak var doge2: UIImageView!
    @IBOutlet weak var dogeOne: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var smallPoster: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bigPoster: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        loadrelated()
        loadVideos()
        loadExtraDetail()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        
        infoView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        //scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + collectionView.frame.origin.y + collectionView.frame.height + 80)
        
        if videos != nil {
        let video = videos![0]
        print(video)
        if let key = video["key"] as? String{
            print(key)
            let htm = "<!DOCTYPE HTML> <html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:og=\"http://opengraphprotocol.org/schema/\" xmlns:fb=\"http://www.facebook.com/2008/fbml\"> <head></head> <body style=\"margin:0 0 0 0; padding:0 0 0 0;\"> <iframe width=\"320\" height=\"180\" src=\"http://www.youtube.com/embed/\(key)\" frameborder=\"0\"></iframe> </body> </html> ";
            videoView.loadHTMLString(htm, baseURL: nil)
            print(htm)
        }
        }
        if let title = movies["title"] as? String {
            titleLabel.text = title
        }
        
        if let year = movies["release_date"] as? String {
            let index = year.startIndex.advancedBy(4)
            titleLabel.text = titleLabel.text! + " (\(year.substringToIndex(index)))"
        }
        
        if let overview = movies["overview"] as? String {
            overviewLabel.text = overview
            overviewLabel.sizeToFit()
        }
        
        if let language = movies["original_language"] as? String {
            languageLabel.text = language
        }
        
        if let rating = movies["vote_average"] {
            let value = rating.integerValue!
            if value >= 8 {
                self.dogeOne.hidden = false
                self.doge2.hidden = false
                self.doge3.hidden = false
            } else if value >= 6 {
                self.dogeOne.hidden = false
                self.doge2.hidden = false
            } else if value >= 4 {
                self.dogeOne.hidden = false
            }
            let ratingText = rating.stringValue
            ratingLabel.text = ratingText + "/10"
        }
        
        if let posterPath = movies["poster_path"] as? String {
            let smallUrl = "https://image.tmdb.org/t/p/w45"
            let baseUrl = "https://image.tmdb.org/t/p/original"
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallUrl + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
            bigPoster.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.bigPoster.alpha = 0.0
                    self.bigPoster.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.bigPoster.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.bigPoster.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.bigPoster.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
            smallPoster.setImageWithURLRequest(
                largeImageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.smallPoster.alpha = 0.0
                        self.smallPoster.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.smallPoster.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.smallPoster.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
        }
        
        let ypostition = overviewLabel.frame.origin.y + overviewLabel.frame.height + 5
        smallPoster.frame.origin.y = ypostition
        smallPoster.alpha = 1
        let secondYPosition = ypostition + 10
        ratingLabel.frame.origin.y = secondYPosition
        rating.frame.origin.y = ypostition
        let thirdYposition = secondYPosition + ratingLabel.frame.height
        dogeOne.frame.origin.y = thirdYposition
        doge2.frame.origin.y = thirdYposition
        doge3.frame.origin.y = thirdYposition
        taglineLabel.frame.origin.y = smallPoster.frame.origin.y + smallPoster.frame.height + 5
        videoView.frame.origin.y = taglineLabel.frame.origin.y + taglineLabel.frame.height + 5
        relatedMLabel.frame.origin.y = videoView.frame.origin.y + videoView.frame.height + 5
        relatedLeft.frame.origin.y = relatedMLabel.frame.origin.y + 9
        relatedRight.frame.origin.y = relatedMLabel.frame.origin.y + 9
        collectionView.frame.origin.y = relatedMLabel.frame.origin.y + relatedMLabel.frame.height + 5
        
        //scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + collectionView.frame.origin.y + collectionView.frame.height)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadExtraDetail() {
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let preId = movies["id"]
        let id = preId!.stringValue
        print(id)
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(id)?api_key=\(apiKey)")
        print("first")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        print("second")
        
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary
                            if let tagline = self.movies["tagline"] as? String {
                                self.taglineLabel.text = "\"" + "\(tagline)" + "\""
                            }
                    }
                }
        })
        task.resume()
        print("third")
    }
    
    func loadVideos() {
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let preId = movies["id"]
        let id = preId!.stringValue
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let tasker: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.videos = responseDictionary["results"] as? [NSDictionary]
                            self.setUpView()
                    }
                }
        })
        tasker.resume()
    }
    
    func loadrelated() {
        let apiKey = "c68f8545f6273075aa8a018e3fe6a5ab"
        let preId = movies["id"]
        let id = preId!.stringValue
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(id)/similar?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let tasker: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.related = responseDictionary["results"] as? [NSDictionary]
                            print(self.related)
                            self.collectionView.reloadData()
                    }
                }
        })
        tasker.resume()
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let related = related {
            return related.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = related![indexPath.row]
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



    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepare for segue")
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = related![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movies = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
