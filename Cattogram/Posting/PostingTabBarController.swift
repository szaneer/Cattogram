//
//  PostingTabBarController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/23/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class PostingTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onCancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
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
