//
//  DetailViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/24/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var fakeBackdropView: UIImageView!
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movie: Movie!
    var backgroundView = UIImageView()
    var related = [Movie]()
    var notTable = false
    var posterImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1500
        
        navigationItem.title = movie.title
        
        if notTable {
            titleLabel.text = movie.title
            posterView.image = posterImage
            overviewLabel.text = movie.overview
            titleLabel.isHidden = false
            posterView.isHidden = false
            overviewLabel.isHidden = false
            dateLabel.isHidden = false
            videoView.isHidden = false
            collectionView.isHidden = false
        }
        
        setupDetails()
    }
    
    func setupDetails() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = dateFormatter.string(from: movie.releaseDate)
        
        videoView.backgroundColor = .black
        
        backgroundView.alpha = 0.0
        backgroundView.frame = fakeBackdropView.frame
        backgroundView.contentMode = .scaleAspectFit
        view.sendSubview(toBack: backgroundView)
        
        let backdropUrlSmall = posterBaseSmall + movie.backdropPath
        let backdropUrlBig = posterBase + movie.backdropPath
        
        let backdropUrlSmallRequest = URLRequest(url: URL(string: backdropUrlSmall)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        let backdropUrlBigRequest = URLRequest(url: URL(string: backdropUrlBig)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        if let cachedImage = URLCache.shared.cachedResponse(for: backdropUrlBigRequest) {
            DispatchQueue.main.async {
                self.backgroundView.image = UIImage(data: cachedImage.data)
            }
        } else {
            downloadImageFromURL(urlRequest: backdropUrlSmallRequest) { (smallBackdrop) in
                DispatchQueue.main.async {
                    self.backgroundView.alpha = 0.0
                    self.backgroundView.image = smallBackdrop
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.backgroundView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        downloadImageFromURL(urlRequest: backdropUrlBigRequest) { (largeBackdrop) in
                            DispatchQueue.main.async {
                                UIView.transition(with: self.backgroundView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                                       self.backgroundView.image = largeBackdrop
                                    }, completion: nil)
                            }
                        }
                    })
                }
            }
        }
        
        MovieClient.sharedInstance.getVideo(id: movie.id, width: Int(view.frame.width - 16), height: Int((view.frame.width - 16) * (9 / 16)), success: { (htm) in
            DispatchQueue.main.async {
                self.videoView.loadHTMLString(htm, baseURL: nil)
            }
        }) {
            print("Error loading video")
        }
        
        MovieClient.sharedInstance.getRelatedMovies(id: movie.id, success: { (movies) in
            self.related = movies
        }) {
            print("Error getting related movies")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.addSubview(backgroundView)
        cell.contentView.sendSubview(toBack: backgroundView)
        cell.selectionStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "detailSegue":
            let destination = segue.destination as! DetailViewController
            let cell = sender as! MovieCollectionCell
            let indexPath = collectionView!.indexPath(for: cell)!
            destination.movie = related[indexPath.row]
            
            destination.posterImage = cell.posterView.image
            destination.notTable = true
        default:
            break
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return related.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionCell
        
        var movie: Movie!
        cell.tag = indexPath.row
        cell.posterView.image = nil
        
        movie = related[indexPath.row]
        
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
