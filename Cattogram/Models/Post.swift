//
//  Post.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/10/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

class Post {

    var caption: String?
    var owner: String
    var likeCount: Int
    var uid: String
    var locationName: String?
    var longitude: Double?
    var latitude: Double?
    var name: String
    var timeStamp: Double
    
    init(postData: [String: Any]) {
        if let caption = postData["caption"] as? String {
            self.caption = caption
        }
        
        owner = postData["owner"] as! String
        likeCount = postData["likeCount"] as! Int
        uid = postData["uid"] as! String
        name = postData["name"] as! String
        timeStamp = postData["timestamp"] as! Double
        
        if let location = postData["location"] as? [String: Any] {
            locationName = location["name"] as? String
            longitude = location["longitude"] as? Double
            latitude = location["latitude"] as? Double
        }
    }
}
