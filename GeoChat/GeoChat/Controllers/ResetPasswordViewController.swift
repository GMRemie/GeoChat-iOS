//
//  ResetPasswordViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase



class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var resetPassword: UIButton!
    
    @IBOutlet weak var emailAddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Round corners
        resetPassword.roundCorners()
    }
    
    @IBAction func resetPasswordClick(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailAddress.text!)
        let alert = UIAlertController(title: "Password reset", message: "If a user for that email address is found, we have sent a password recovery code.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
}
