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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let title = UILabel()
        title.font = UIFont(name: "Billabong", size: 30)
        title.text = "Cattogram"
        self.navigationController?.navigationBar.topItem?.titleView = title
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 30)!]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: .cattoPosted, object: nil)
        
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
        
        if CattogramClient.sharedInstance.lastSnapshot == nil {
            posts = []
        }
        
        CattogramClient.sharedInstance.getPosts(success: { (posts) in
            if posts.count < 1 {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.loadingMoreView?.stopAnimating()
                    self.isMoreDataLoading = false
                }
            } else {
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
    
    @objc func goToProfile(sender: Any) {
        let header = (sender as! UIView).superview as! CattoHeaderView
        
        performSegue(withIdentifier: "profileSegue", sender: header.post.owner)
    }
    
    @objc func goToComments(sender: Any) {
        let cell = (sender as! UIButton).superview!.superview as! CattoCell
        
        performSegue(withIdentifier: "commentSegue", sender: cell.post)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
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
            
        }
        
        headerView.post = post
        
        headerView.nameButton.addTarget(self, action: #selector(goToProfile(sender:)), for: .touchUpInside)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cattoCell", for: indexPath) as! CattoCell

        let post = posts[indexPath.section]
        
        cell.tag = indexPath.section
        cell.index = indexPath.section
        cell.post = post
        cell.commentButton.addTarget(self, action: #selector(goToComments(sender:)), for: .touchUpInside)
        
        return cell
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
