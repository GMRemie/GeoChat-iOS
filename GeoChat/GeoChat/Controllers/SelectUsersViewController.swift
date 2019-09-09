//
//  SelectUsersViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/9/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class SelectUsersViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    var users = [String:String]()
    var curUser: User!
    var reference: DatabaseReference!
    var selected: (String,String)!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        reference = Database.database().reference()
        
        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(curUser.uniqueID).child("social").child("friends")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.loadFriends(data: data)
            }
        }
    }

    func loadFriends(data:NSDictionary){
        let dict = data as! [String:String]
        
        for (k,v) in dict{
            users[k] = v
        }
        
        
        self.tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user")
        let key = Array(users.keys)[indexPath.row]
        cell?.textLabel?.text = users[key]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(users.keys)[indexPath.row]
        // return this info
        selected = (key,users[key]) as! (String, String)
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
