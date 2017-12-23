//
//  RegisterEmailViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/15/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class RegisterEmailViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 5
    }
    
    @IBAction func onTextChange(_ sender: Any) {
        emailField.textColor = .black
        usernameField.textColor = .black
        emailField.textColor = .black
        passwordField.textColor = .black
        
        if emailField.text!.count > 0 && passwordField.text!.count > 0 && nameField.text!.count > 0 && usernameField.text!.count > 0{
            loginButton.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5882352941, blue: 0.9215686275, alpha: 1)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = #colorLiteral(red: 0.6992750764, green: 0.8336177468, blue: 0.9693890214, alpha: 1)
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func onOutsideTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onUnwind(_ sender: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "toCreateSegue":
            let destination = segue.destination as! RegisterCreateViewController
            destination.email = emailField.text
            destination.username = usernameField.text
            destination.name = nameField.text
            destination.password = passwordField.text
        default:
            break
        }
    }
}
