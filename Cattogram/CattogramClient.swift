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
import FBSDKCoreKit

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
    
    func registerUser(name: String?, username: String?, email: String?, password: String?, image: UIImage?, success: @escaping () -> (), failure: @escaping (RegisterError) -> ()) {
        guard let name = name, !name.isEmpty  else {
            failure(RegisterError.emptyInput)
            return
        }
        
        guard let username = username, !username.isEmpty else {
            failure(RegisterError.emptyInput)
            return
        }
        
        guard let email = email, !email.isEmpty  else {
            failure(RegisterError.emptyInput)
            return
        }
        
        guard let password = password, !password.isEmpty  else {
            failure(RegisterError.emptyInput)
            return
        }
        
        if !email.isValidEmail() {
            failure(RegisterError.invalidEmail)
            return
        }
        
        if password.count < 6 {
            failure(RegisterError.shortPassword)
            return
        }
        
        checkUsername(username: username, success: { (exists) in
            if exists {
                failure(RegisterError.usernameTaken)
            } else {
                var userData = ["name": name, "username": username, "email": email, "postCount": 0] as [String : Any]
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        if error.localizedDescription == "The email address is already in use by another account." {
                            failure(RegisterError.emailTaken)
                            return
                        } else {
                            failure(RegisterError.generic)
                            return
                        }
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
                                failure(RegisterError.generic)
                            } else {
                                success()
                            }
                        })
                    }
                }
            }
        }) { (error) in
            failure(RegisterError.generic)
        }
        
    }
    
    func changeUserProfileImage(user: String, image: UIImage!, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        userImagesCollection.document(user).setData(["image" : base64EncodeImage(image)]) { (error) in
            if let error = error {
                failure(error)
            } else {
                success()
            }
        }
    }
    func checkUsername(username: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        userCollection.whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                if snapshot.count > 0 {
                    success(true)
                } else {
                    success(false)
                }
            }
        }
    }
    
    func loginWithFacebook(credential: AuthCredential, success: @escaping (User, [String: Any], Bool) -> (), failure: @escaping (Error) -> ()) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start { (request, result, error) in
            if let error = error {
                failure(error)
            } else if let result = result {
                let userInfo = result as! [String: Any]
                
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        failure(error)
                    } else if let user = user {
                        self.userCollection.document(user.uid).getDocument(completion: { (userDoc, error) in
                            if let error = error {
                                failure(error)
                            } else if userDoc!.exists {
                                success(user, userInfo, true)
                            } else {
                                success(user, userInfo, false)
                            }
                        })
                        
                    }
                }
            }
        }
        
    }
    
    func registerUserWithFacebook(uid: String, name: String?, username: String?, email: String?, image: UIImage?, success: @escaping () -> (), failure: @escaping (RegisterError) -> ()) {
        guard let name = name, !name.isEmpty  else {
            failure(RegisterError.emptyInput)
            return
        }
        
        guard let username = username, !username.isEmpty else {
            failure(RegisterError.emptyInput)
            return
        }
        
        guard let email = email, !email.isEmpty  else {
            failure(RegisterError.emptyInput)
            return
        }
        
        if !email.isValidEmail() {
            failure(RegisterError.invalidEmail)
            return
        }
        
        checkUsername(username: username, success: { (exists) in
            if exists {
                failure(RegisterError.usernameTaken)
            } else {
                let userData = ["uid": uid, "name": name, "username": username, "email": email, "postCount": 0] as [String : Any]
                        
                let userDocument = self.userCollection.document(uid)
                let userImageDocument = self.userImagesCollection.document(uid)
                
                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.setData(userData, forDocument: userDocument)
                    
                    if let image = image {
                        let imageString = base64EncodeImage(image)
                        transaction.setData(["image": imageString], forDocument: userImageDocument)
                    } else {
                        transaction.setData([:], forDocument: userImageDocument)
                    }
                    
                    return nil
                }, completion: { (_, error) in
                    if error != nil {
                        failure(RegisterError.generic)
                    } else {
                        success()
                    }
                })
                
            }
        }) { (error) in
            failure(RegisterError.generic)
        }
        
        checkUsername(username: username, success: { (exists) in
            if exists {
                failure(RegisterError.usernameTaken)
            } else {
                let userData = ["uid": uid, "name": name, "username": username, "email": email, "postCount": 0] as [String : Any]
                
                self.userCollection.document(uid).setData(userData, completion: { (error) in
                    if error != nil {
                        failure(RegisterError.generic)
                    } else {
                        success()
                    }
                })
            }
        }) { (error) in
            failure(RegisterError.generic)
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
    
    func getUserLikeStatus(post: String, user: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        postLikes.document(post).getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                let postLikeData = snapshot.data()
                
                if postLikeData[user] == nil {
                    success(false)
                } else {
                    success(true)
                }
            }
        }
    }
    
    func likePost(post: String, user: String, success: @escaping (Int) -> (), failure: @escaping (Error) -> ()) {
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var postDoc: DocumentSnapshot
            do {
                postDoc = try transaction.getDocument(self.postCollection.document(post))
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let postData = postDoc.data()
            
            var likeCount = postData["likeCount"] as! Int
            likeCount += 1
            
            transaction.updateData(["likeCount" : likeCount], forDocument: self.postCollection.document(post))
            transaction.updateData([user : true], forDocument: self.postLikes.document(post))
            
            return likeCount
        }) { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(object as! Int)
            }
        }
    }
    
    func unLikePost(post: String, user: String, success: @escaping (Int) -> (), failure: @escaping (Error) -> ()) {
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var postDoc: DocumentSnapshot
            var postLikeDoc: DocumentSnapshot
            do {
                postDoc = try transaction.getDocument(self.postCollection.document(post))
                postLikeDoc = try transaction.getDocument(self.postLikes.document(post))
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let postData = postDoc.data()
            var postLikeData = postLikeDoc.data()
            
            var likeCount = postData["likeCount"] as! Int
            likeCount -= 1
            postLikeData.removeValue(forKey: user)
            
            transaction.updateData(["likeCount" : likeCount], forDocument: self.postCollection.document(post))
            transaction.setData(postLikeData, forDocument: self.postLikes.document(post))
            
            return likeCount
        }) { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(object as! Int)
            }
        }
    }
    
    func postComment(post: String, user: String, comment: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        var commentData = ["owner": user, "comment": comment, "timestamp": Double(Date().timeIntervalSince1970)] as [String : Any]
        
        let postCommentsDocument = self.postComments.document(post)
        
        getUserInfo(uid: user, success: { (user) in
            commentData["name"] = user.name
            
            postCommentsDocument.collection("comments").document().setData(commentData, completion: { (error) in
                if let error = error {
                    failure(error)
                } else {
                    success()
                }
            })
        }) { (error) in
            failure(error)
        }
    }
    
    func getPostComments(post: String, success: @escaping ([Comment]) -> (), failure: @escaping (Error) -> ()) {
        
        self.postComments.document(post).collection("comments").order(by: "timestamp", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                let documents = snapshot.documents
                
                var comments: [Comment] = []
                
                for document in documents {
                    let commentData = document.data()
                    
                    comments.append(Comment(commentData: commentData))
                }
                
                success(comments)
            }
        }
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
    
    func checkIfCatto
}

func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
    UIGraphicsBeginImageContext(imageSize)
    image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage!)
    UIGraphicsEndImageContext()
    return resizedImage!
}

func resizeAndCrop(image: UIImage, newSize: CGSize) -> UIImage {
    let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
    resizeImageView.image = image
    
    UIGraphicsBeginImageContext(resizeImageView.frame.size)
    resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
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

enum RegisterError: Error, LocalizedError {
    case emptyInput
    case invalidEmail
    case shortPassword
    case usernameTaken
    case emailTaken
    case generic
    
    public var errorDescription: String? {
        switch self {
        case .emptyInput:
            return NSLocalizedString("Please fill out all fields.", comment: "Register error")
        case .invalidEmail:
            return NSLocalizedString("Invalid email address. Please use a valid email address.", comment: "Register error")
        case .shortPassword:
            return NSLocalizedString("Password must be atleast six characters in length.", comment: "Register error")
        case .usernameTaken:
            return NSLocalizedString("Username is taken. Please use a different one.", comment: "Register error")
        case .emailTaken:
            return NSLocalizedString("Email is taken. Please use a different one.", comment: "Register error")
        case .generic:
            return NSLocalizedString("Error registering. Please try again.", comment: "Register error")
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
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

extension Notification.Name {
    static let cattoPosted = Notification.Name("cattoPosted")
}
