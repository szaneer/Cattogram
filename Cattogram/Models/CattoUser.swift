
//
//  CattoUser.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/10/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class CattoUser {
    var email: String!
    var postCount: Int
    var uid: String
    var name: String
    var username: String
    
    init(userData: [String: Any]) {
        email = userData["email"] as! String
        postCount = userData["postCount"] as! Int
        uid = userData["uid"] as! String
        name = userData["name"] as! String
        username = userData["username"] as! String
    }
}
