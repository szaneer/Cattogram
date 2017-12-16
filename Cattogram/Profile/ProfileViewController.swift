//
//  ProfileViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/10/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIImage(named: "background")!
        navigationController?.navigationBar.setBackgroundImage(background, for: .default)
        
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
        
        loadUserInfo()
    }

    func loadUserInfo() {
        CattogramClient.sharedInstance.getUserInfo(uid: Auth.auth().currentUser!.uid, success: { (user) in
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
        
        cell.cattoView.image = UIImage(named: "image_placeholder")
        cell.tag = indexPath.section
        
        CattogramClient.sharedInstance.getPostImage(uid: post.uid, success: { (image) in
            DispatchQueue.main.async {
                if cell.tag == indexPath.section {
                    cell.cattoView.image = image
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
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
            headerView.nameLabel.frame.offsetBy(dx: 0, dy: 30)
        }
        
        
        // let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        headerView.profileView.clipsToBounds = true
        headerView.profileView.layer.cornerRadius = 15;
        headerView.profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        headerView.profileView.layer.borderWidth = 1;
        CattogramClient.sharedInstance.getUserImage(uid: post.owner, success: { (image) in
            if let image = image {
                headerView.profileView.image = image
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        headerView.nameLabel.text = post.name
        
        
        
        return headerView
    }
    
}

