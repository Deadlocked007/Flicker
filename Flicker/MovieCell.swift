//
//  MovieCell.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie! {
        didSet {
            posterView.image = nil
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            titleLabel.textColor = .black
            overviewLabel.textColor = .black
            titleLabel.sizeToFit()
            if let posterPath = movie.posterPath {
                let posterUrlSmall = posterBaseSmall + posterPath
                let posterUrlBig = posterBase + posterPath
                let posterUrlSmallRequest = URLRequest(url: URL(string: posterUrlSmall)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
                let posterUrlBigRequest = URLRequest(url: URL(string: posterUrlBig)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
                if let cachedImage = URLCache.shared.cachedResponse(for: posterUrlBigRequest) {
                    DispatchQueue.main.async {
                        if (self.tag == self.index) {
                            self.posterView.image = UIImage(data: cachedImage.data)
                        }
                    }
                } else {
                    downloadImageFromURL(urlRequest: posterUrlSmallRequest) { (smallPoster) in
                        DispatchQueue.main.async {
                            if (self.tag == self.index) {
                                self.posterView.alpha = 0.0
                                self.posterView.image = smallPoster
                            }
                            
                            
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                
                                self.posterView.alpha = 1.0
                                
                            }, completion: { (sucess) -> Void in
                                
                                downloadImageFromURL(urlRequest: posterUrlBigRequest) { (largePoster) in
                                    DispatchQueue.main.async {
                                        if (self.tag == self.index) {
                                            UIView.transition(with: self.posterView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                                                self.posterView.image = largePoster
                                            }, completion: nil)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
            
            //self.selectionStyle = .none
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.darkGray
            self.selectedBackgroundView = backgroundView
        }
    }
    
    var index: Int!
}
