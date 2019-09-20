//
//  CreateBizPostViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class CreateBizPostViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {


    var profile:User!
    
    var imagePicker:UIImagePickerController!
    
    var path:DatabaseReference!
    
    var coordinates: CLLocationCoordinate2D!
    
    var users = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    
}
