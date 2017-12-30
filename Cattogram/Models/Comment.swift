//
//  Comment.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

class Comment {
    
    var comment: String
    var owner: String
    var name: String
    var timeStamp: Double
    
    init(commentData: [String: Any]) {
        
        comment = commentData["comment"] as! String
        owner = commentData["owner"] as! String
        name = commentData["name"] as! String
        timeStamp = commentData["timestamp"] as! Double
    }
}

