//
//  AdminLogViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class AdminLogViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    

    var userUID: String!
    var handle: String!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var handleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bioLbl: UILabel!
    
    
    
    
    var DatabaseRef: DatabaseReference!
    var userPath: DatabaseReference!
    var messages = [GeoMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseRef = Database.database().reference()
        userPath = DatabaseRef.child("users").child(userUID)
        
        handleLbl.text = "@\(handle!)"
        
        
        userPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                self.loadUserInfo(data: snap)
            }
        }
        
    }
    
    
    func loadUserInfo(data: NSDictionary){
        // k is keys v is value we're already in the correct location
        
        let biotext = (data["bio"] as? String) ?? "No bio"
        
        bioLbl.text = biotext
        
        let storage = Storage.storage().reference()
        let storageRef = storage.child(userUID)
        let avatarRef = storageRef.child("avatar/avatar.jpg")
        
        avatarRef.downloadURL { (url, Error) in
            if (Error != nil){
                print(Error?.localizedDescription)
                return
            }
            let configuration = URLSessionConfiguration.default
            let session = URLSession.init(configuration: configuration)
            let task = session.dataTask(with: url!, completionHandler: { (data, response, Error) in
                if (Error != nil){
                    print(Error?.localizedDescription)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                    print("Error")
                    return
                }
                DispatchQueue.main.async {
                    self.avatar.image = UIImage(data: data!)
                }
            })
            task.resume()
        }
        loadAllUsersMessages()
        
    }
    
    func loadAllUsersMessages(){
        self.messages.removeAll()
        let publicMessagesRef = DatabaseRef.child("public")
        publicMessagesRef.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                for (_,v) in snap{
                    let values = v as! NSDictionary
                    if ((values["author"] as! String) == self.userUID ){
                        let url = values["url"] as! String
                        let date = values["date"] as! String
                        
                        let newmessage = GeoMessage(title: "", lat: 0.0, long: 0.0, author: self.userUID, caption: "", url: url, id: "", privacy: false, biz: false, date: date, exp: 0)
                        
                        self.messages.append(newmessage)
                        print(self.messages.count)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LogTableViewCell
        
        let messasge = messages[indexPath.row]
        
        cell.dateLbl.text = messasge.date
        // load our image
        let url = URL(string: messasge.url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url!) { (data, response, Error) in
            if (Error != nil){
                print(Error?.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                print("Error")
                return
            }
            DispatchQueue.main.async {
                cell.messageImg.image = UIImage(data: data!)
            }
        }
        task.resume()   

        
        return cell
    }


    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
