//
//  DetailSegue.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/24/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class DetailSegue: UIStoryboardSegue {

    var index: Int!
    var movie: Movie!
    
    override func perform() {
        let sourceController = source as! MoviesViewController
        let destinationController = destination as! DetailViewController
        let indexPath = IndexPath(row: index, section: 0)
        let cell = sourceController.tableView.cellForRow(at: indexPath) as! MovieCell
        print(cell.titleLabel)
        
        let sourceView = source.view as! UIView
        let destinationView = destination.view as! UIView
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let window = UIApplication.shared.keyWindow
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = sourceView.bounds
        blurVisualEffectView.alpha = 0.0
        blurVisualEffectView.frame = blurVisualEffectView.frame.offsetBy(dx: 0, dy: (sourceController.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height - sourceController.tableView.contentOffset.y)
        window?.insertSubview(blurVisualEffectView, aboveSubview: destinationView)
        
        cell.removeFromSuperview()
        cell.frame = cell.frame.offsetBy(dx: 0, dy: -sourceController.tableView.contentOffset.y)
        cell.backgroundColor = .clear
        
        window?.insertSubview(cell, aboveSubview: blurVisualEffectView)
        
        sourceController.tableView.separatorStyle = .none
        UIView.animate(withDuration: 0.4, animations: {
            cell.frame = CGRect(x: 0, y: (sourceController.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height, width: screenWidth, height: cell.frame.height)
            blurVisualEffectView.alpha = 1.0
        }) { (finished) in
            UIView.animate(withDuration: 0.4, animations: {
                cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: screenWidth, height: screenHeight)
                
            }, completion: { (finished) in
                self.source.navigationController?.pushViewController(self.destination, animated: true)
                
                sourceView.isHidden = true
                UIView.animate(withDuration: 0.4, animations: {
                    cell.overviewLabel.textColor = .white
                    cell.titleLabel.textColor = .white
                }, completion: { (finished) in
                    UIView.animate(withDuration: 0.4, animations: {
                        cell.titleLabel.frame = destinationController.titleLabel.frame
                        cell.posterView.frame = destinationController.posterView.frame
                        cell.overviewLabel.frame = CGRect(x: destinationController.overviewLabel.frame.origin.x, y: destinationController.overviewLabel.frame.origin.y, width: destinationController.overviewLabel.frame.width, height: cell.overviewLabel.frame.height)
                        cell.overviewLabel.sizeToFit()
                        destinationController.backgroundView.alpha = 1.0
                        destinationController.titleLabel.text = cell.titleLabel.text
                        destinationController.posterView.image = cell.posterView.image
                        destinationController.overviewLabel.text = cell.overviewLabel.text
                        blurVisualEffectView.alpha = 0.0
                        destinationController.dateLabel.isHidden = false
                        destinationController.videoView.isHidden = false
                        destinationController.collectionView.isHidden = false
                    }, completion: { (finished) in
                        destinationController.titleLabel.sizeToFit()
                        destinationController.overviewLabel.sizeToFit()
                        destinationController.titleLabel.isHidden = false
                        destinationController.posterView.isHidden = false
                        destinationController.overviewLabel.isHidden = false
                        blurVisualEffectView.removeFromSuperview()
                        cell.removeFromSuperview()
                        sourceController.tableView.dataSource = nil
                        sourceController.tableView.reloadData()
                        sourceController.tableView.dataSource = sourceController
                    })
                })
            })
            
        }
        
    }
}
