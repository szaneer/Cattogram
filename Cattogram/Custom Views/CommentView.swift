//
//  CommentView.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import FirebaseAuth

class CommentView: UIView {

    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var postButton: UIButton!
    
    var post: Post! {
        didSet {
            commentField.placeholder = "Add a comment as \(post.name)..."
            commentContainerView.layer.cornerRadius = 26
            commentContainerView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
            commentContainerView.layer.borderWidth = 1
            commentContainerView.clipsToBounds = true
            
            
            
            profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
            profileView.layer.borderWidth = 1
            CattogramClient.sharedInstance.getUserImage(uid: Auth.auth().currentUser!.uid, success: { (profileImage) in
                self.profileView.image = profileImage
                self.profileView.layer.cornerRadius = self.profileView.frame.width / 2
                self.profileView.layer.masksToBounds = true
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }
    }

    @IBAction func onType(_ sender: Any) {
        guard let text = commentField.text else {
            postButton.isEnabled = false
            return
        }
        
        if text.count > 0 {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
}
