//
//  Helper.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

let posterBase = "https://image.tmdb.org/t/p/original"
let posterBaseSmall = "https://image.tmdb.org/t/p/w45"

func downloadImageFromURL(urlRequest: URLRequest, success: @escaping (UIImage) -> ()) {
    DispatchQueue.global().async {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        config.urlCache = URLCache.shared
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil {
                return
            } else if let data = data {
                
                let cacheResponse = CachedURLResponse(response: response!, data: data)
                URLCache.shared.storeCachedResponse(cacheResponse, for: urlRequest)
                
                
                guard let image = UIImage(data: data) else {
                    return
                }
                success(image)
            }
        })
        task.resume()
    }
}

extension CGRect {
    func copy() -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.width, height: self.height)
    }
}
