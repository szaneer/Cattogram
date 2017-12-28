//
//  ProfileImageSelectedViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/22/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileImageSelectedViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doneButton.layer.cornerRadius = 5
        
        profileImageView.image = image
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2.0
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.black.cgColor
    }

    @IBAction func onChange(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "takePhotoSegue", sender: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "selectFromLibrarySegue", sender: nil)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = doneButton.center
        doneButton.setTitle("", for: .normal)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        CattogramClient.sharedInstance.changeUserProfileImage(user: Auth.auth().currentUser!.uid, image: image, success: {
            self.performSegue(withIdentifier: "doneSegue", sender: nil)
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: "There was an error setting your profile image. Please try again." , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.doneButton.setTitle("Done", for: .normal)
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
