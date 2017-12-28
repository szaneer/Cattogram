//
//  CattoHeaderView.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/10/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class CattoHeaderView: UIView {

    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    var post: Post! {
        didSet {
            // let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            backgroundColor = UIColor(white: 1.0, alpha: 0.9)
            profileView.clipsToBounds = true
            profileView.layer.cornerRadius = 15
            profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
            profileView.layer.borderWidth = 1
            CattogramClient.sharedInstance.getUserImage(uid: post.owner, success: { (image) in
                if let image = image {
                    self.profileView.image = image
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            nameLabel.text = post.name
        }
    }
}
