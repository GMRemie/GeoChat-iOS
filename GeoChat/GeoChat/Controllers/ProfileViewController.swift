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
    
    var sent = [String:String]()
    var received = [String:String]()
    var friends = [String:String]()
    
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var photosCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        handleLabel.text = "@\(userInfo!.handle!)"
        profilePicture.image = userInfo.avatar
        
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        loadBio()
 
        
        let curUser = Auth.auth().currentUser!
        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(curUser.uid).child("social")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.updateFriends(data: data)
            }
        }
    }
    
    func updateFriends(data:NSDictionary){
        
        sent.removeAll()
        received.removeAll()
        friends.removeAll()
        
        // Our Following, Followers, and friends
        let dict = data as! [String:Any]
        for (k,v) in dict{
            switch k{
            case "following":
                for (handle,id) in v as! [String:String]{
                    sent[id] = handle
                }
                
                break
            case "follower":
                for (handle,id) in v as! [String:String]{
                    received[id] = handle
                }
                break
                
            default:
                // friends
                break
            }
            
        }
        
        followersLabel.text = "\(received.count)"
        followingLabel.text = "\(sent.count)"
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
