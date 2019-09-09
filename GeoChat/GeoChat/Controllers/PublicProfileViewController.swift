//
//  PublicProfileViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/9/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class PublicProfileViewController: UIViewController {

    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var bio: UILabel!
    var userInfo: User!
    @IBOutlet weak var followButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle.text = userInfo.handle!
        
        userInfo.getAvatFromUID(id: userInfo.uniqueID, image: avatar)
        
        loadBio()
    }
    
    func loadBio(){
        
        let dataRef = Database.database().reference()
        userInfo.getBio(ref: dataRef, label: bio)
    }


    @IBAction func followClicked(_ sender: UIButton) {
    }
    @IBAction func reportClicked(_ sender: UIButton) {
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
