//
//  CommentCell.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var post: Post! {
        didSet {
            let currTime = Date().timeIntervalSince1970
            let diff = currTime - post.timeStamp
            
            if diff < 60 {
                timeLabel.text = "JUST NOW"
            } else if diff < 3600 {
                timeLabel.text = "\(Int(diff / 60)) MINUTES AGO"
            } else { // if diff < 86400 {
                timeLabel.text = "\(Int(diff / 3600)) HOURS AGO"
            }
            
            if var caption = post.caption {
                caption = post.name + " " + caption
                
                let attributedString = NSMutableAttributedString(string: caption)
                
                let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)]
                
                let nameRange = (caption as NSString).range(of: post.name)
                
                
                attributedString.addAttributes(boldFontAttribute, range: nameRange)
                
                
                commentLabel.attributedText = attributedString
            }
            
            profileView.clipsToBounds = true
            profileView.layer.cornerRadius = profileView.frame.width / 2
            profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
            profileView.layer.borderWidth = 1
            CattogramClient.sharedInstance.getUserImage(uid: post.owner, success: { (image) in
                if let image = image {
                    self.profileView.image = image
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    var comment: Comment! {
        didSet {
            let currTime = Date().timeIntervalSince1970
            let diff = currTime - comment.timeStamp
            
            if diff < 60 {
                timeLabel.text = "JUST NOW"
            } else if diff < 3600 {
                timeLabel.text = "\(Int(diff / 60)) MINUTES AGO"
            } else { // if diff < 86400 {
                timeLabel.text = "\(Int(diff / 3600)) HOURS AGO"
            }
            
            let text = comment.name + " " + comment.comment
            
            let attributedString = NSMutableAttributedString(string: text)
            
            let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)]
            
            let nameRange = (text as NSString).range(of: comment.name)
            
            
            attributedString.addAttributes(boldFontAttribute, range: nameRange)
            
            
            commentLabel.attributedText = attributedString
            
            
            profileView.clipsToBounds = true
            profileView.layer.cornerRadius = profileView.frame.width / 2
            profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
            profileView.layer.borderWidth = 1
            CattogramClient.sharedInstance.getUserImage(uid: comment.owner, success: { (image) in
                if let image = image {
                    self.profileView.image = image
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
