//
//  CattoCell.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import FirebaseAuth

class CattoCell: UITableViewCell {

    @IBOutlet weak var cattoView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bigLikeView: UIImageView!
    
    var isLiked = false
    var index: Int!
    
    var post: Post! {
        didSet {
            isUserInteractionEnabled = false
            
            likeLabel.text = "\(post.likeCount) likes"
            
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
                
                
                captionLabel.attributedText = attributedString
            }
            
            cattoView.image = UIImage(named: "image_placeholder")
            
            CattogramClient.sharedInstance.getPostImage(uid: post.uid, success: { (image) in
                DispatchQueue.main.async {
                    if self.tag == self.index{
                        self.cattoView.image = image
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }

            self.likeButton.setImage(UIImage(named: "likeIcon"), for: .normal)
            
            CattogramClient.sharedInstance.getUserLikeStatus(post: post.uid, user: Auth.auth().currentUser!.uid, success: { (liked) in
                if liked {
                    self.likeButton.setImage(UIImage(named: "likeIconRed"), for: .normal)
                    self.isLiked = true
                }
                self.isUserInteractionEnabled = true
            }) { (error) in
                print(error.localizedDescription)
                self.isUserInteractionEnabled = true
            }
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            
            cattoView.addGestureRecognizer(doubleTap)
        }
    }
    
    @IBAction func onLike(_ sender: Any) {
        isUserInteractionEnabled = false
        if !isLiked {
            CattogramClient.sharedInstance.likePost(post: post.uid, user: Auth.auth().currentUser!.uid, success: { (newCount) in
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.likeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: {(_ finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                        self.likeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.likeButton.setImage(UIImage(named: "likeIconRed"), for: .normal)
                        self.isLiked = !self.isLiked
                        self.likeLabel.text = "\(newCount) likes"
                        self.isUserInteractionEnabled = true
                    })
                })
            }, failure: { (error) in
                print(error.localizedDescription)
                self.isUserInteractionEnabled = true
            })
        } else {
            CattogramClient.sharedInstance.unLikePost(post: post.uid, user: Auth.auth().currentUser!.uid, success: { (newCount) in
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.likeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: {(_ finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                        self.likeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.likeButton.setImage(UIImage(named: "likeIcon"), for: .normal)
                        self.isLiked = !self.isLiked
                        self.likeLabel.text = "\(newCount) likes"
                        self.isUserInteractionEnabled = true
                    })
                })
            }, failure: { (error) in
                print(error.localizedDescription)
                self.isUserInteractionEnabled = true
            })
        }
        
    }
    
    @IBAction func onDoubleTap(_ sender: Any) {
        isUserInteractionEnabled = false
        if !isLiked {
            bigLikeView.isHidden = false
            CattogramClient.sharedInstance.likePost(post: post.uid, user: Auth.auth().currentUser!.uid, success: { (newCount) in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.bigLikeView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.bigLikeView.alpha = 1.0
                }, completion: {(_ finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                        self.bigLikeView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: {(_ finished: Bool) -> Void in
                        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                            self.bigLikeView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            self.bigLikeView.alpha = 0.0
                        }, completion: {(_ finished: Bool) -> Void in
                            self.bigLikeView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                                self.likeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                            }, completion: {(_ finished: Bool) -> Void in
                                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                                    self.likeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    self.likeButton.setImage(UIImage(named: "likeIconRed"), for: .normal)
                                    self.isLiked = !self.isLiked
                                    self.likeLabel.text = "\(newCount) likes"
                                    self.isUserInteractionEnabled = true
                                    self.bigLikeView.isHidden = true
                                })
                            })
                        })
                    })
                })
            }, failure: { (error) in
                print(error.localizedDescription)
                self.isUserInteractionEnabled = true
            })
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
