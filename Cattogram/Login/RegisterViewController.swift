//
//  RegisterViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    
    var gradientColors: [(first: UIColor, second: UIColor)] = []
    var currGradient = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImage(named: "background")!
        navigationController?.navigationBar.setBackgroundImage(background, for: .default)
        
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        
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
    
    @IBAction func onRegister(_ sender: Any) {
        CattogramClient.sharedInstance.registerUser(name: nameField.text, email: emailField.text, password: passwordField.text, image: profileImageView.image, success: {
            self.performSegue(withIdentifier: "registerSegue", sender: nil)
        }) { (error) in
            print(error.localizedDescription)
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
