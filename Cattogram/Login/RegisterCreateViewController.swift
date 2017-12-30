//
//  RegisterCreateViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/22/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class RegisterCreateViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    var email: String?
    var username: String?
    var name: String?
    var password: String?
    var facebookData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = 5
    }

    @IBAction func onOutsideTap(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func onNext(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = nextButton.center
        nextButton.setTitle("", for: .normal)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if let facebookData = facebookData {
            let picture = facebookData["picture"] as! [String: Any]
            let data = picture["data"] as! [String: Any]
            let pictureURL = URL(string: data["url"] as! String)!
            let pictureSession = URLSession(configuration: .default)
            pictureSession.dataTask(with: pictureURL) { (data, response, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        self.performSegue(withIdentifier: "registerErrorSegue", sender: error)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } else if let data = data {
                    let image = UIImage(data: data)!
                    CattogramClient.sharedInstance.registerUserWithFacebook(uid: facebookData["uid"] as! String, name: self.name, username: self.username, email: self.email, image: image, success: {
                        self.performSegue(withIdentifier: "facebookDoneSegue", sender: nil)
                    }, failure: { (error) in
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                            self.performSegue(withIdentifier: "registerErrorSegue", sender: error)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                
            }.resume()
            
        } else {
            CattogramClient.sharedInstance.registerUser(name: name, username: username, email: email, password: password, image: nil, success: {
                self.performSegue(withIdentifier: "registerCompleteSegue", sender: nil)
            }) { (error) in
                print(error.localizedDescription)
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    self.performSegue(withIdentifier: "registerErrorSegue", sender: error)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "registerErrorSegue":
            let destination = segue.destination as! RegisterEmailViewController
            let error = sender as! RegisterError
            switch error {
                case .emptyInput:
                    print("asds")
                    if email == nil || email!.isEmpty {
                        destination.emailField.textColor = .red
                    }
                
                    if username == nil || username!.isEmpty {
                        destination.usernameField.textColor = .red
                    }
                
                    if name == nil || name!.isEmpty {
                        destination.nameField.textColor = .red
                    }
                
                    if password == nil || password!.isEmpty {
                        destination.passwordField.textColor = .red
                    }
                case .invalidEmail:
                    destination.emailField.textColor = .red
                case .shortPassword:
                    destination.passwordField.textColor = .red
                case .usernameTaken:
                    destination.usernameField.textColor = .red
                case .emailTaken:
                    destination.emailField.textColor = .red
                default:
                    return
            }
        default:
            return
        }
    }
    
}
