//
//  CattogramClient.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/8/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

class CattogramClient {
    static let sharedInstance = CattogramClient()
    
    let db = Firestore.firestore()
    let userCollection = Firestore.firestore().collection("user")
    let userImagesCollection = Firestore.firestore().collection("userImages")
    
    let postCollection = Firestore.firestore().collection("post")
    let postImagesCollection = Firestore.firestore().collection("postImages")
    let postLikes = Firestore.firestore().collection("postLikes")
    let postComments = Firestore.firestore().collection("postComments")
    
    func loginUser(email: String?, password: String?, success: @escaping () -> (), failure: @escaping (LoginError) -> ()) {
        guard let email = email else {
            failure(LoginError.badInput)
            return
        }
        
        guard let password = password else {
            failure(LoginError.badInput)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                failure(LoginError.authentication)
            } else if user != nil {
                success()
            }
        }
    }
    
    func registerUser(name: String?, email: String?, password: String?, image: UIImage?, success: @escaping () -> (), failure: @escaping (RegisterError) -> ()) {
        guard let name = name else {
            failure(RegisterError.badInput)
            return
        }
        
        guard let email = email else {
            failure(RegisterError.badInput)
            return
        }
        
        guard let password = password else {
            failure(RegisterError.badInput)
            return
        }
        
        var userData = ["name": name, "email": email, "postCount": 0] as [String : Any]
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                failure(RegisterError.authentication)
            } else if let user = user {
                userData["uid"] = user.uid
                
                let userDocument = self.userCollection.document(user.uid)
                let userImageDocument = self.userImagesCollection.document(user.uid)
                
                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.setData(userData, forDocument: userDocument)
                    
                    if let image = image {
                        let imageString = base64EncodeImage(image)
                        transaction.setData(["image": imageString], forDocument: userImageDocument)
                    } else {
                        transaction.setData([:], forDocument: userImageDocument)
                    }
                    
                    return user
                }, completion: { (user, error) in
                    if error != nil {
                        if let user = user as? User {
                            user.delete(completion: nil)
                        }
                        failure(RegisterError.data)
                    } else {
                        success()
                    }
                })
            }
        }
    }
    
    func createPost(user: String, text: String?, image: UIImage?, success: @escaping () -> (), failure: @escaping (PostError) -> ()) {
        guard let text = text else {
            failure(PostError.badInput)
            return
        }
        
        guard let image = image else {
            failure(PostError.badInput)
            return
        }
        
        var postData = ["caption": text, "owner": user, "favoriteCount": 0] as [String : Any]
        
        let postDocument = self.postCollection.document()
        let postImageDocument = self.postImagesCollection.document(postDocument.documentID)
        let postLikesDocument = self.postLikes.document(postDocument.documentID)
        let postCommentsDocument = self.postComments.document(postDocument.documentID)
        
        postData["uid"] = postDocument.documentID
        
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.setData(postData, forDocument: postDocument)
            transaction.setData([:], forDocument: postLikesDocument)
            transaction.setData([:], forDocument: postCommentsDocument)
            
            let imageString = base64EncodeImage(image)
            transaction.setData(["image": imageString], forDocument: postImageDocument)
            
            return nil
        }, completion: { (_, error) in
            if error != nil {
                failure(PostError.data)
            } else {
                success()
            }
        })
    }
}

func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
    UIGraphicsBeginImageContext(imageSize)
    image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage!)
    UIGraphicsEndImageContext()
    return resizedImage!
}

func base64EncodeImage(_ image: UIImage) -> String {
    var imagedata = UIImagePNGRepresentation(image)
    
    let oldSize: CGSize = image.size
    let newSize: CGSize = CGSize(width: 200, height: oldSize.height / oldSize.width * 200)
    imagedata = resizeImage(newSize, image: image)
    return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
}

func base64DecodeImage(_ data: String) -> UIImage {
    let data = Data(base64Encoded: data, options: .ignoreUnknownCharacters)!
    
    return UIImage(data: data)!
}

enum RegisterError: Error {
    case badInput
    case authentication
    case data
}

enum LoginError: Error {
    case badInput
    case authentication
}

enum PostError: Error {
    case badInput
    case missingImage
    case data
}
