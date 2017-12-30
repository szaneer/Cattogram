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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let uid = uid {
            if uid == Auth.auth().currentUser!.uid {
                self.uid = nil
            }
        }
        
        loadUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
        tableController.mainViewController = self
    }

    func loadUserInfo() {
        if let uid = uid {
            editProfileButton.setTitle("Follow", for: .normal)
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

    @objc func goToProfile(sender: Any) {
        let header = (sender as! UIView).superview as! CattoHeaderView
        
        performSegue(withIdentifier: "profileSegue", sender: header.post.owner)
    }
    
    @objc func goToComments(sender: Any) {
        let cell = (sender as! UIButton).superview!.superview as! CattoCell
        
        performSegue(withIdentifier: "commentSegue", sender: cell.post)
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

    @objc func deletePost(sender: Any) {
        let header = (sender as! UIButton).superview as! CattoHeaderView
        let post = header.post
        
        let alertController = UIAlertController(title: "Delete Catto", message: "Are you sure you want to delete this catto?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            CattogramClient.sharedInstance.deletePost(post: post!, success: {
                self.loadUserInfo()
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "profileSegue":
            let destination = segue.destination as! ProfileViewController
            destination.uid = sender as? String
        case "commentSegue":
            let destination = segue.destination as! CommentsViewController
            destination.post = sender as! Post
        default:
            return
        }
    }
}

extension ProfileViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
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
    weak var mainViewController: ProfileViewController!
    
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
        
        cell.commentButton.addTarget(mainViewController, action: #selector(mainViewController.goToComments(sender:)), for: .touchUpInside)
        
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
        
        headerView.nameButton.addTarget(mainViewController, action: #selector(mainViewController.goToProfile(sender:)), for: .touchUpInside)
        
        headerView.editButton.addTarget(mainViewController, action: #selector(mainViewController.deletePost(sender:)), for: .touchUpInside)
        
        return headerView
    }
    
}

