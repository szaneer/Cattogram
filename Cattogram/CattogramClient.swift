//
//  CattogramClient.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/8/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import MapKit

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
    
    func createPost(user: String, caption: String?, image: UIImage?, mapItem: MKMapItem?, success: @escaping () -> (), failure: @escaping (PostError) -> ()) {
        guard let image = image else {
            failure(PostError.badInput)
            return
        }
        
        guard let caption = caption else {
            failure(PostError.badInput)
            return
        }
        
        var postData = ["caption": caption, "owner": user, "likeCount": 0, "timestamp": Double(Date().timeIntervalSince1970)] as [String : Any]
    
        if let mapItem = mapItem {
            postData["location"] = ["name": mapItem.name!, "latitude": Double(mapItem.placemark.location!.coordinate.latitude), "longitude": Double(mapItem.placemark.location!.coordinate.longitude)]
        }
        
        let userDocument = self.userCollection.document(user)
        let postDocument = self.postCollection.document()
        let postImageDocument = self.postImagesCollection.document(postDocument.documentID)
        let postLikesDocument = self.postLikes.document(postDocument.documentID)
        let postCommentsDocument = self.postComments.document(postDocument.documentID)
        
        postData["uid"] = postDocument.documentID
        
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            var userSnapshot: DocumentSnapshot
            do {
                userSnapshot = try transaction.getDocument(userDocument)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let userData = userSnapshot.data()
            let newPostCount = (userData["postCount"] as! Int) + 1
            transaction.updateData(["postCount": newPostCount], forDocument: userDocument)
            
            postData["name"] = userData["name"] as! String
            
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
    
    var lastSnapshot: DocumentSnapshot?
    
    func getPosts(success: @escaping ([Post]) -> (), failure: @escaping (PostError) -> ()) {
        var postQuery = postCollection.order(by: "timestamp", descending: true).limit(to: 20)
        
        if let lastSnapshot = lastSnapshot {
            postQuery = postQuery.start(afterDocument: lastSnapshot)
        }
        
        postQuery.getDocuments(completion: { (snapshot, error) in
            if error != nil {
                failure(PostError.retrieval)
                return
            }
            
            var posts: [Post] = []
            
            guard let snapshot = snapshot else {
                success(posts)
                return
            }
            
            if snapshot.documents.count <= 0 {
                success(posts)
                return
            }
            
            for document in snapshot.documents {
                posts.append(Post(postData: document.data()))
            }
            
            self.lastSnapshot = snapshot.documents.last
            
            success(posts)
        })
    }
    
    func getUserPosts(uid: String, success: @escaping ([Post]) -> (), failure: @escaping (PostError) -> ()) {
        let postQuery = postCollection.whereField("owner", isEqualTo: uid)
        
        postQuery.getDocuments(completion: { (snapshot, error) in
            if error != nil {
                failure(PostError.retrieval)
                return
            }
            
            var posts: [Post] = []
            
            guard let snapshot = snapshot else {
                success(posts)
                return
            }
            
            if snapshot.documents.count <= 0 {
                success(posts)
                return
            }
            
            for document in snapshot.documents {
                posts.append(Post(postData: document.data()))
            }
            
            success(posts)
        })
    }
    
    func getPostImage(uid: String, success: @escaping (UIImage) -> (), failure: @escaping (PostError) -> ()) {
        postImagesCollection.document(uid).getDocument { (snapshot, error) in
            if error != nil {
                failure(PostError.image)
                return
            } else if let snaphot = snapshot {
                let imageString = snaphot.data()["image"] as! String
                success(base64DecodeImage(imageString))
            }
        }
    }
    
    func getUserImage(uid: String, success: @escaping (UIImage?) -> (), failure: @escaping (PostError) -> ()) {
        userImagesCollection.document(uid).getDocument { (snapshot, error) in
            if error != nil {
                failure(PostError.image)
                return
            } else if let snapshot = snapshot {
                if let imageString = snapshot.data()["image"] as? String {
                    success(base64DecodeImage(imageString))
                } else {
                    success(nil)
                }
            }
        }
    }
    
    func getUserInfo(uid: String, success: @escaping (CattoUser) -> (), failure: @escaping (PostError) -> ()) {
        userCollection.document(uid).getDocument { (snapshot, error) in
            if error != nil {
                failure(PostError.image)
                return
            } else if let snapshot = snapshot {
                success(CattoUser(userData: snapshot.data()))
            }
        }
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
    let newSize: CGSize = CGSize(width: 400, height: oldSize.height / oldSize.width * 400)
    imagedata = resizeImage(newSize, image: image)
    return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
}

func base64DecodeImage(_ data: String) -> UIImage {
    let data = Data(base64Encoded: data, options: .ignoreUnknownCharacters)!
    
    return UIImage(data: data)!
}

func parseAddress(selectedItem: MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
        format:"%@%@%@%@%@%@%@",
        // street number
        selectedItem.subThoroughfare ?? "",
        firstSpace,
        // street name
        selectedItem.thoroughfare ?? "",
        comma,
        // city
        selectedItem.locality ?? "",
        secondSpace,
        // state
        selectedItem.administrativeArea ?? ""
    )
    return addressLine
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
    case retrieval
    case image
}
