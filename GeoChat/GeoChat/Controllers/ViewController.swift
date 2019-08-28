//
//  ViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/27/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gradientVIew: UIView!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       gradientVIew.setGradient(colorOne: Colors.blue, colorTwo: Colors.middle_blue, colorThree: Colors.bottom_blue)
        
        // round our button
        signUpButton.roundCorners()
        loginButton.roundCorners()
        
        
        // Load life cycle
        // check to see if user has any user defaults and check if it logs in
        
        
    }

    @IBAction func signUpClicked(_ sender: UIButton) {
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
    }
}

