//
//  RegisterViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var fbButton: FBSDKLoginButton!
    
    var gradientColors: [(first: UIColor, second: UIColor)] = []
    var currGradient = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbButton.delegate = self
        
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
    
    @IBAction func unwindFromRegisterEmailViewController(_ sender: UIStoryboardSegue) {
        //performSegue(withIdentifier: "unwindToLoginSegue", sender: nil)
    }
    
}

extension RegisterViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if (result.isCancelled) {
            return
        }
        
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
