//
//  ProfileViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/9/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    
    var userInfo: User!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var userBio: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleLabel.text = "@\(userInfo!.handle!)"
        profilePicture.image = userInfo.avatar
        
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        loadBio()
 
    }
    
    

    
    func loadBio(){
        let dataRef = Database.database().reference()
        userInfo.getBio(ref: dataRef, label: userBio)
    }
    
    
    @IBAction func signoutClicked(_ sender: UIButton) {
        
        if Auth.auth().currentUser != nil{
            let confirm = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirm.addAction(UIAlertAction(title: "Log out", style: .default, handler: { (UIAlertAction) in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                self.performSegue(withIdentifier: "signOut", sender: self)
            }))
            
            self.present(confirm, animated: true)
            
        }
        
    }
    
    // user profile pages
    

}
