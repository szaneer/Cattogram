//
//  CattosViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class CattosViewController: UITableViewController {

    var posts: [Post] = []
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        
        loadPosts()
    }

    @objc func loadPosts() {
        if isMoreDataLoading {
            return
        }
        
        isMoreDataLoading = true
        
        if refreshControl!.isRefreshing {
            CattogramClient.sharedInstance.lastSnapshot = nil
        }
        
        CattogramClient.sharedInstance.getPosts(success: { (posts) in
            if self.refreshControl!.isRefreshing {
                self.posts = posts
            } else {
                self.posts.append(contentsOf: posts)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.loadingMoreView?.stopAnimating()
                self.isMoreDataLoading = false
            }
        }) { (error) in
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.loadingMoreView?.stopAnimating()
                self.isMoreDataLoading = false
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                print("wew")
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadPosts()
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            headerView.profileView.image = image
        }) { (error) in
            print(error.localizedDescription)
        }
        
        headerView.nameLabel.text = post.name
        
        
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cattoCell", for: indexPath) as! CattoCell

        let post = posts[indexPath.section]
        
        CattogramClient.sharedInstance.getPostImage(uid: post.uid, success: { (image) in
            cell.cattoView.image = image
        }) { (error) in
            print(error.localizedDescription)
        }

        return cell
    }
}
