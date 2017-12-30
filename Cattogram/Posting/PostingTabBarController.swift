//
//  PostingTabBarController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/23/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class PostingTabBarController: UITabBarController {

    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @IBAction func onCancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNext(_ sender: Any) {
        let photoSelectController = self.viewControllers![0] as! CreateViewController
        
        photoSelectController.performSegue(withIdentifier: "postSegue", sender: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Photo" {
            nextButton.isHidden = true
        } else {
            nextButton.isHidden = false
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
