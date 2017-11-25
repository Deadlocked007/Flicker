//
//  VideoViewController.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/25/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIWebView!
    
    var id: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MovieClient.sharedInstance.getVideo(id: id, width: Int(view.frame.width), height: Int(videoView.frame.height), success: { (htm) in
            self.videoView.loadHTMLString(htm, baseURL: nil)
        }) {
            self.dismiss(animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
