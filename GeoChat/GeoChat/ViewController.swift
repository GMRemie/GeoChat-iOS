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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       gradientVIew.setGradient(colorOne: Colors.blue, colorTwo: Colors.middle_blue, colorThree: Colors.bottom_blue)
        
    }


}

