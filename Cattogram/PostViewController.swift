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

protocol PostViewControllerDelegate {
    func locationSelect(mapItem: MKMapItem)
}

class PostViewController: UITableViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionView: UITextView!
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var image: UIImage!
    var mapItem: MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postImageView.image = image
        
        tableView.rowHeight = UITableViewAutomaticDimension
        let lastView = UIView()
        tableView.tableFooterView = lastView
    }
    
    @IBAction func onShare(_ sender: Any) {
        CattogramClient.sharedInstance.createPost(user: Auth.auth().currentUser!.uid, caption: captionView.text, image: postImageView.image, mapItem: mapItem, success: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
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
