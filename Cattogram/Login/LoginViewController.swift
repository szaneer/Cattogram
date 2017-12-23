//
//  LoginViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/8/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var cattogramLabel: UILabel!
    @IBOutlet weak var cattogramLabelConstraint: NSLayoutConstraint!
    
    var gradientColors: [(first: UIColor, second: UIColor)] = []
    var currGradient = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //5396EB
        cattogramLabelConstraint.constant = UIApplication.shared.statusBarFrame.height + 44
        
        loginButton.layer.cornerRadius = 5
        
        fbLoginButton.delegate = self
        
        let background = UIImage(named: "background")!
        navigationController?.navigationBar.setBackgroundImage(background, for: .default)
        
        gradientColors.append((first: #colorLiteral(red: 0.2274509804, green: 0.2549019608, blue: 0.8823529412, alpha: 1), second: #colorLiteral(red: 0.4705882353, green: 0.168627451, blue: 0.7254901961, alpha: 1)))
        gradientColors.append((first: #colorLiteral(red: 0.4705882353, green: 0.168627451, blue: 0.7254901961, alpha: 1), second: #colorLiteral(red: 0.8039215686, green: 0.1803921569, blue: 0.4352941176, alpha: 1)))
        gradientColors.append((first: #colorLiteral(red: 0.8039215686, green: 0.1803921569, blue: 0.4352941176, alpha: 1), second: #colorLiteral(red: 0.8862745098, green: 0.3960784314, blue: 0.2588235294, alpha: 1)))
        gradientColors.append((first: #colorLiteral(red: 0.8862745098, green: 0.3960784314, blue: 0.2588235294, alpha: 1), second: #colorLiteral(red: 0.9607843137, green: 0.7960784314, blue: 0.4784313725, alpha: 1)))
        animateGradient()
    }
    
    func animateGradient() {
        UIView.transition(with: gradientView, duration: 15, options: [.transitionCrossDissolve], animations: {
            self.gradientView.gradientStartColor = self.gradientColors[self.currGradient].first
            self.gradientView.gradientEndColor = self.gradientColors[self.currGradient].second
        }) { (didAnimate) in
            self.currGradient += 1
            self.currGradient %= self.gradientColors.count
            self.animateGradient()
        }
    }
    
    @IBAction func onTextChange(_ sender: Any) {
        if emailField.text!.count > 0 && passwordField.text!.count > 0 {
            loginButton.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5882352941, blue: 0.9215686275, alpha: 1)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = #colorLiteral(red: 0.6992750764, green: 0.8336177468, blue: 0.9693890214, alpha: 1)
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = loginButton.center
        loginButton.setTitle("", for: .normal)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        CattogramClient.sharedInstance.loginUser(email: emailField.text, password: passwordField.text, success: {
            activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error) in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.loginButton.setTitle("Login", for: .normal)
            let alertController = UIAlertController(title: "Error", message: "There was an issue while trying to login. Please try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if (result.isCancelled) {
            return
        }
        
        print(result.description)
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        CattogramClient.sharedInstance.loginWithFacebook(credential: credential, success: { (user, userData, exists) in
            if exists {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}
