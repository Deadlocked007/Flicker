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

func downloadImageFromURL(url: String, success: @escaping (UIImage) -> ()) {
    DispatchQueue.global().async {
        guard let url = URL(string: url) else {
            return
        }
        
        guard let imageData = try? Data(contentsOf: url) else {
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            return
        }
        
        success(image)
    }
}
