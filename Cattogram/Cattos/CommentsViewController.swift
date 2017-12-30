//
//  CommentsViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import FirebaseAuth

class CommentsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    var post: Post!
    var commentView: CommentView!
    var keyboardHeight: CGFloat?
    var comments: [Comment] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let views = Bundle.main.loadNibNamed("CommentView", owner: nil, options: nil)
        
        commentView = views?[0] as! CommentView
        
        commentView.post = post
        
        commentView.frame = tabBarController!.tabBar.frame
        
        commentView.postButton.addTarget(self, action: #selector(postComment(sender:)), for: .touchUpInside)
        
        self.view.addSubview(commentView)
        
        tableViewHeightConstraint.constant = commentView.frame.origin.y
        
        tabBarController?.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func postComment(sender: Any) {
        view.endEditing(true)
        commentView.commentField.isUserInteractionEnabled = false
        commentView.postButton.isUserInteractionEnabled = false
        let comment = commentView.commentField.text!
        
        CattogramClient.sharedInstance.postComment(post: post.uid, user: Auth.auth().currentUser!.uid, comment: comment, success: {
            self.commentView.commentField.text = ""
            self.commentView.postButton.isUserInteractionEnabled = true
            self.commentView.commentField.isUserInteractionEnabled = true
            self.commentView.postButton.isEnabled = false
            DispatchQueue.main.async {
                self.loadComments()
            }
        }) { (error) in
            print(error.localizedDescription)
            self.commentView.postButton.isUserInteractionEnabled = true
            self.commentView.commentField.isUserInteractionEnabled = true
        }
    }
    
    func loadComments() {
        CattogramClient.sharedInstance.getPostComments(post: post.uid, success: { (comments) in
            self.comments = comments
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            commentView.frame.origin.y -= keyboardSize.size.height + 6
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            commentView.frame.origin.y += keyboardSize.size.height + 6
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return comments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell

        if indexPath.section == 0 {
            cell.post = post
        } else {
            cell.comment = comments[indexPath.row]
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.frame.width, bottom: 0, right: 0)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
