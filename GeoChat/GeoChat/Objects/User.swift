//
//  User.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class User{
    
    let email: String!
    let uniqueID: String!
    let handle: String!
    let avatar: UIImage?
    var bizAccount = false
    
    init(_email:String?,_id:String,_handle:String,_avatar:UIImage?) {
        self.email = _email ?? "Empty"
        self.uniqueID = _id
        self.handle = _handle
        self.avatar = _avatar ?? nil
    }
    
    
    // All followers, following, and friends follow the same type of Handle - UID
    
    // Get Followers
    func getUsersFollowers(){
        let dRef = Database.database().reference()
        
        let followerPath = dRef.child("users").child(uniqueID).child("followers")
        
        followerPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                for (k,v) in data{
                }
            }
        }
        
    }
    // Get following
    func getUsersFollowing(){
        let dRef = Database.database().reference()
        
        let followerPath = dRef.child("users").child(uniqueID).child("following")
        
        followerPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                for (k,v) in data{
                }
            }
        }
        
    }
    
    
    // Get Friends
    func getUsersFriends(){
        let dRef = Database.database().reference()
        
        let followerPath = dRef.child("users").child(uniqueID).child("friends")
        
        followerPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                for (k,v) in data{
                }
            }
        }
        
    }
    
    
    func getBio(ref:DatabaseReference,label:UILabel){
        let userPath = ref.child("users").child(uniqueID)
        
        userPath.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                if let bio = snap["bio"] as? String {
                    label.text = bio
                }else{
                    label.text = "This user has no bio"
                }
            }
        })
        
    }
    
    func getAvatFromUID(id:String,image:UIImageView){
        print("Getting avatar")
        let storage = Storage.storage().reference()
        let storageRef = storage.child(id)
        let avatarRef = storageRef.child("avatar/avatar.jpg")
        
        avatarRef.downloadURL(completion: { (url, Error) in
            if (Error != nil){
                print("ERror downloading url")
            }else{
                let config = URLSessionConfiguration.default
                let session = URLSession.init(configuration: config)
                
                let task = session.dataTask(with: url!, completionHandler: { (Data, Response, Error) in
                    
                    if (Error != nil){
                        print(Error!.localizedDescription)
                        return
                    }
                    
                    guard let response = Response as? HTTPURLResponse, response.statusCode == 200 else{
                        print("Error getting HTTP REsponse")
                        return
                    }
                    print("got image")
                    let avatar = UIImage(data: Data!, scale: 0.5)
                    self.assignImage(view: image, image: avatar!)

                    

                })
                task.resume()
            }
        })
        
    }
    
    func assignImage(view:UIImageView,image:UIImage){
        DispatchQueue.main.async {
            view.image = image
            view.setNeedsDisplay()
            view.layer.cornerRadius = view.bounds.height/2

        }
    }
    
}
