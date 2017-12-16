//
//  PreCreateViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class PreCreateViewController: UIViewController {

    var forward = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if forward {
            forward = false
            performSegue(withIdentifier: "createSegue", sender: nil)
        } else {
            forward = true
            tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "createSeuge":
            break
        default:
            break
        }
    }
    

}
