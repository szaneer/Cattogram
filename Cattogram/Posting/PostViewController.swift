//
//  PostViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import RSKPlaceholderTextView

protocol PostViewControllerDelegate {
    func locationSelect(mapItem: MKMapItem)
}

class PostViewController: UITableViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionView: RSKPlaceholderTextView!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var profileView: UIImageView!
    
    var image: UIImage!
    var mapItem: MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileView.layer.cornerRadius = self.profileView.frame.width / 2
        profileView.layer.masksToBounds = true
        
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1
        CattogramClient.sharedInstance.getUserImage(uid: Auth.auth().currentUser!.uid, success: { (profileImage) in
            self.profileView.image = profileImage
        }) { (error) in
            print(error.localizedDescription)
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        postImageView.image = image
        
        tableView.rowHeight = UITableViewAutomaticDimension
        let lastView = UIView()
        tableView.tableFooterView = lastView
    }
    
    @IBAction func onShare(_ sender: Any) {
        view.isUserInteractionEnabled = false
        CattogramClient.sharedInstance.checkIfCatto(image: postImageView.image!, success: { (hasCatto) in
            if hasCatto {
                DispatchQueue.main.sync {
                    CattogramClient.sharedInstance.createPost(user: Auth.auth().currentUser!.uid, caption: self.captionView.text, image: self.postImageView.image, mapItem: self.mapItem, success: {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                        self.view.isUserInteractionEnabled = true
                        CattogramClient.sharedInstance.lastSnapshot = nil
                        NotificationCenter.default.post(name: .cattoPosted, object: nil)
                    }) { (error) in
                        print(error.localizedDescription)
                        self.view.isUserInteractionEnabled = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                }
                let alertController = UIAlertController(title: "Hmmm", message: "Cattogram can't detect a catto in your picture, please try to take a better picture.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
            }
            let alertController = UIAlertController(title: "Error", message: "There was an issue while chceking for cattos please try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "locationSelectSegue":
            let destination = segue.destination as! PostLocationSearchViewController
            destination.delegate = self
        default:
            break
        }
    }
}

extension PostViewController: PostViewControllerDelegate {
    func locationSelect(mapItem: MKMapItem) {
        self.mapItem = mapItem
        locationCell.textLabel?.text = mapItem.name
    }
    
}
