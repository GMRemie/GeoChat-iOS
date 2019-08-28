//
//  LoginViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize button
        signupButton.roundCorners()
        
        
    }
    
    
    @IBAction func signupClicked(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (AuthDataResult, Error) in
            if (Error != nil){
                let alert = UIAlertController(title: "Error!", message: "Error signing in to this account! Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert, animated: true)
            }
            
            if (AuthDataResult?.user != nil){
                print("Signed in succesfully")
            }
        }
        
    }
    
    
    @IBAction func forgotPassword(_ sender: UIButton) {
    }
}
