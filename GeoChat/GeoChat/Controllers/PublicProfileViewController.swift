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
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    var curUser: User!
    
    var sent = [String:String]()
    var received = [String:String]()
    var friends = [String:String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        followersLabel.text = "0"
        followingLabel.text = "0"
        
        handle.text = userInfo.handle!
        
        userInfo.getAvatFromUID(id: userInfo.uniqueID, image: avatar)
        
        loadBio()
        
        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(userInfo.uniqueID).child("social")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.updateFriends(data: data)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReportViewController{
            destination.reported = userInfo
            destination.reporter = curUser
        }
    }
    
    
    
    func updateFriends(data:NSDictionary){
        
        sent.removeAll()
        received.removeAll()
        
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
            case "friends":
                for (handle,id) in v as! [String:String]{
                    friends[id] = handle
                }
                break
            default:
                // friends
                break
            }
            
        }
        
        followersLabel.text = "\(received.count)"
        followingLabel.text = "\(sent.count)"
        
        // Update button
        if sent.values.contains(curUser.uniqueID){
            // in sent
            followButton.setTitle("Accept", for: .normal)
        }else if received.values.contains(curUser.uniqueID){
            followButton.setTitle("Sent", for: .normal)

            
        }else if friends.values.contains(curUser.uniqueID){
            // friends
            followButton.setTitle("Friends", for: .normal)
            
        }else{
            followButton.setTitle("Follow", for: .normal)
        }
    }
    
    
    func loadBio(){
        
        let dataRef = Database.database().reference()
        userInfo.getBio(ref: dataRef, label: bio)
    }


    @IBAction func followClicked(_ sender: UIButton) {
        
        let dRef = Database.database().reference()
        
        
        let targetSocialPath = dRef.child("users").child(userInfo.uniqueID).child("social")
        let ourSocialPath = dRef.child("users").child(curUser.uniqueID).child("social")
        
        if sent.values.contains(curUser.uniqueID){
            // in sent
            // do nothing
            return
        }else if received.values.contains(curUser.uniqueID){
            // receive/
            // Delete the following from the target and set both to friends
            targetSocialPath.child("following").child(userInfo.uniqueID).setValue(nil)
            ourSocialPath.child("follower").child(curUser.uniqueID).setValue(nil)
            // set friends!
            
            ourSocialPath.child("friends").setValue([userInfo.uniqueID:userInfo.handle])
            targetSocialPath.child("friends").setValue([curUser.uniqueID:curUser.handle])
            let notification = Notification(id: curUser.uniqueID, handle: curUser.handle, note: "became friends", type: 0)
            targetSocialPath.child("notifications").childByAutoId().setValue(notification.toDict())
            
            
            return
        }else if friends.values.contains(curUser.uniqueID){
            // friends
            // do nothing
            return
        }else{
            // follow
            // Update ours first
            ourSocialPath.child("following").setValue([userInfo.uniqueID:userInfo.handle])
            
            targetSocialPath.child("follower").setValue([curUser.uniqueID:curUser.handle])
            
            let notification = Notification(id: curUser.uniqueID, handle: curUser.handle, note: "followed you", type: 1)
            targetSocialPath.child("notifications").childByAutoId().setValue(notification.toDict())
            
            
            
        }
        
    }
    @IBAction func reportClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reportUser", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
