//
//  ProfileImageSelectViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/22/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class ProfileImageSelectViewController: UIViewController {

    @IBOutlet weak var cameraIconContainerView: UIView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addPhotoButton.layer.cornerRadius = 5
        
        cameraIconContainerView.layer.cornerRadius = cameraIconContainerView.frame.height / 2.0
        cameraIconContainerView.layer.borderWidth = 2
        cameraIconContainerView.layer.borderColor = UIColor.black.cgColor
    }

    @IBAction func onOutsideTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onAddPhoto(_ sender: Any) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
