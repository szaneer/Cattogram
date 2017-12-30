//
//  ProfileViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/10/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UITableViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var switchBar: UITabBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userPostsTableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    let collectionController = ProfilePostsCollectionViewController()
    let tableController = ProfilePostsTableViewController()
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel.isHidden = true
        editProfileButton.layer.borderColor = UIColor.black.cgColor
        editProfileButton.layer.cornerRadius = 5
        editProfileButton.layer.borderWidth = 0.5
        
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 75 / 2
        self.userImageView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        self.userImageView.layer.borderWidth = 1
        
        switchBar.selectedItem = switchBar.items?[0]
        switchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        
        collectionView.delegate = collectionController
        collectionView.dataSource = collectionController
        
        userPostsTableView.delegate = tableController
        userPostsTableView.dataSource = tableController
        userPostsTableView.estimatedRowHeight = 250
        userPostsTableView.rowHeight = UITableViewAutomaticDimension
        
        if let uid = uid {
            if uid == Auth.auth().currentUser!.uid {
                self.uid = nil
            }
        }
        
        loadUserInfo()
    }

    func loadUserInfo() {
        if let uid = uid {
            CattogramClient.sharedInstance.getUserInfo(uid: uid, success: { (user) in
                self.navigationItem.title = user.username
                self.nameLabel.text = user.name
                self.postCountLabel.text = "\(user.postCount)"
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            CattogramClient.sharedInstance.getUserImage(uid: uid, success: { (image) in
                if let image = image {
                    self.userImageView.image = image
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            CattogramClient.sharedInstance.getUserPosts(uid: uid, success: { (posts) in
                self.collectionController.posts = posts
                self.tableController.posts = posts
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.userPostsTableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            if Auth.auth().currentUser?.uid == nil {
                return
            }
            CattogramClient.sharedInstance.getUserInfo(uid: Auth.auth().currentUser!.uid, success: { (user) in
                self.navigationItem.title = user.username
                self.nameLabel.text = user.name
                self.postCountLabel.text = "\(user.postCount)"
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            CattogramClient.sharedInstance.getUserImage(uid: Auth.auth().currentUser!.uid, success: { (image) in
                if let image = image {
                    self.userImageView.image = image
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            CattogramClient.sharedInstance.getUserPosts(uid: Auth.auth().currentUser!.uid, success: { (posts) in
                self.collectionController.posts = posts
                self.tableController.posts = posts
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.userPostsTableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        
        do {
           try Auth.auth().signOut()
        } catch let error {
            
        }
        FBSDKLoginManager().logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }

}

extension ProfileViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Heloo")
        if item == switchBar.items?[0] {
            userPostsTableView.isHidden = true
            collectionView.isHidden = false
        } else {
            collectionView.isHidden = true
            userPostsTableView.isHidden = false
        }
    }
}

class ProfilePostsCollectionViewController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var posts: [Post] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIApplication.shared.keyWindow!.frame.width / 3.0 - 0.5, height: UIApplication.shared.keyWindow!.frame.width / 3.0 - 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! CreateCell
        
        let post = posts[indexPath.row]
        
        cell.imageView.image = UIImage(named: "image_placeholder")
        cell.tag = indexPath.row
        
        CattogramClient.sharedInstance.getPostImage(uid: post.uid, success: { (image) in
            DispatchQueue.main.async {
                if cell.tag == indexPath.row {
                    cell.imageView.image = image
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        return cell
    }
}

class ProfilePostsTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var posts: [Post] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cattoCell", for: indexPath) as! CattoCell
        
        let post = posts[indexPath.section]
        
        cell.tag = indexPath.section
        cell.index = indexPath.section
        cell.post = post
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let post = posts[section]
        
        let views = Bundle.main.loadNibNamed("CattoHeaderView", owner: nil, options: nil)
        
        var headerView: CattoHeaderView!
        if let locationName = post.locationName {
            headerView = views?[0] as! CattoHeaderView
            headerView.locationButton.setTitle("\(locationName) >", for: .normal)
        } else {
            headerView = views?[1] as! CattoHeaderView
            //headerView.nameLabel.frame.offsetBy(dx: 0, dy: 30)
        }
        
        
        headerView.post = post
        
        
        return headerView
    }
    
}

