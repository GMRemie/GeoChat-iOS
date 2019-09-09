//
//  SearchViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/7/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase


class SearchViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource {

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var handlesStorage = [String:String]()
    var results = [User]()
    
    var sent = [String:String]()
    var received = [String:String]()
    var friends = [String:String]()
    
    var curUser: User!
    
    var selectedUser: User!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let curUser = Auth.auth().currentUser!
        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(curUser.uid).child("social")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.updateFriends(data: data)
            }
        }
    }
    
    // Handling our sent,received friends
    
    func updateFriends(data:NSDictionary){
        
        sent.removeAll()
        received.removeAll()
        friends.removeAll()
        
        print(data)
        // Our Following, Followers, and friends
        let dict = data as! [String:Any]
        for (k,v) in dict{
            switch k{
            case "following":
                print("Sent already1")
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
                for (handle,id) in v as! [String:String]{
                    friends[id] = handle
                }
                break
            }
            
        }

        tableView.reloadData()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        searchBar.endEditing(true)
        searchFirebase(handle: searchBar.text!)
    }
    
    
    func searchFirebase(handle:String){
        handlesStorage.removeAll()
        results.removeAll()
        let reference = Database.database().reference()
        let handles = reference.child("handles")
        handles.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                for (key,value) in data{
                    self.handlesStorage[key as! String] = value as! String
                }
                // Now filter
                let sortedStorage = self.handlesStorage.filter({$0.key.lowercased().contains(handle.lowercased())})
                self.processResultsToUsers(dict: sortedStorage)
            }
        }
 
    }

    func processResultsToUsers(dict:[String:String]){
        let reference = Database.database().reference()
        for (k,v) in dict{
            let path = reference.child("users").child(v)
            path.observeSingleEvent(of: .value) { (DataSnapshot) in
                if let data = DataSnapshot.value as? NSDictionary{
                    let resultUser = User(_email: "empty", _id: v, _handle: k, _avatar: nil)
                    self.results.append(resultUser)
                    if (self.results.count == dict.count){
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(results.count)
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultTableViewCell
        let info = results[indexPath.row]
        cell.handle.text = "@\(results[indexPath.row].handle!)"
        cell.detailButton.tag = indexPath.row
        
        cell.detailButton.addTarget(self, action: #selector(socialClicked(sender:)), for: .touchUpInside)

        
        // spaghetti fix
        if sent.values.contains(info.uniqueID){
            // in sent
            cell.detailButton.setTitle("Sent", for: .normal)
        }else if received.values.contains(info.uniqueID){
            cell.detailButton.setTitle("Accept", for: .normal)

        }else if friends.values.contains(info.uniqueID){
            // friends
            cell.detailButton.setTitle("Friends", for: .normal)

        }else{
            cell.detailButton.setTitle("Follow", for: .normal)
        }
        
        
        
        
        return cell
    }
    
    @objc func socialClicked(sender: UIButton){
        let clickedUser = results[sender.tag]
        
        let dRef = Database.database().reference()
       
        
        let targetSocialPath = dRef.child("users").child(clickedUser.uniqueID).child("social")
        let ourSocialPath = dRef.child("users").child(curUser.uniqueID).child("social")

        
        // First update our social status with them if needed
        if sent.values.contains(clickedUser.uniqueID){
            // in sent
            // do nothing
            return
        }else if received.values.contains(clickedUser.uniqueID){
                // receive/
             // Delete the following from the target and set both to friends
            targetSocialPath.child("following").child(curUser.uniqueID).setValue(nil)
            ourSocialPath.child("follower").child(clickedUser.uniqueID).setValue(nil)
            // set friends!
            
            ourSocialPath.child("friends").setValue([clickedUser.uniqueID:clickedUser.handle])
            targetSocialPath.child("friends").setValue([curUser.uniqueID:curUser.handle])
            let notification = Notification(id: curUser.uniqueID, handle: curUser.handle, note: "became friends", type: 0)
            targetSocialPath.child("notifications").childByAutoId().setValue(notification.toDict())

            
            return
        }else if friends.values.contains(clickedUser.uniqueID){
            // friends
            // do nothing
            return
        }else{
            // follow
            // Update ours first
            ourSocialPath.child("following").setValue([clickedUser.uniqueID:clickedUser.handle])
            
            targetSocialPath.child("follower").setValue([curUser.uniqueID:curUser.handle])
            
            let notification = Notification(id: curUser.uniqueID, handle: curUser.handle, note: "followed you", type: 1)
            targetSocialPath.child("notifications").childByAutoId().setValue(notification.toDict())


            
        }
        
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        // Send out a notification
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = results[indexPath.row]
        print(selectedUser.handle)
       performSegue(withIdentifier: "displayUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PublicProfileViewController{
            destination.userInfo = selectedUser
        }
    }

}
