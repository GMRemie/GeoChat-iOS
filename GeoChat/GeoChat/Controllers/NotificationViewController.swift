//
//  NotificationViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/9/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    
    
    var notifications = [String:Notification]()
    var curUser:User!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(curUser.uniqueID).child("social").child("notifications")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.loadNotifications(data: data)
            }
        }
    }
    
    func loadNotifications(data:NSDictionary){
        notifications.removeAll()
        let dict = data as! [String:Any]
        
        for (k,v) in dict{
            let note = v as! [String:Any]
            let id = note["id"] as! String
            let handle = note["handle"] as! String
            let detail = note["note"] as! String
            let type = note["type"] as! Int
            let notification = Notification(id: id, handle: handle, note: detail, type: type)
            notifications[k] = notification
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifyFriend") as! NotificationTableViewCell
        cell.detailButton.tag = indexPath.row
        cell.key = Array(notifications.keys)[indexPath.row]
        let notification = notifications[cell.key]
        cell.handle.text = "\(notification!.handle) \(notification!.note)"
        if (notification?.type == 0){
            cell.detailButton.isHidden = true
        }else{
            cell.detailButton.addTarget(self, action: #selector(socialClicked(sender:)), for: .touchUpInside)

        }
        
        let storage = Storage.storage().reference()
        let storageRef = storage.child(notification!.userID)
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
                    cell.avatar.image = UIImage(data: data!)
                }
            })
            task.resume()
        }
        
        return cell
    }
    @objc func socialClicked(sender: UIButton){
        let position = sender.tag
        let key = Array(notifications.keys)[position]
        let notification = notifications[key]

        
        let dRef = Database.database().reference()
        
        
        let targetSocialPath = dRef.child("users").child((notification?.userID)!).child("social")
        let ourSocialPath = dRef.child("users").child(curUser.uniqueID).child("social")

        
        targetSocialPath.child("following").child(curUser.uniqueID).setValue(nil)
        ourSocialPath.child("follower").child((notification?.userID)!).setValue(nil)
        // set friends!
        
        ourSocialPath.child("friends").setValue([notification?.userID:notification?.handle])
        targetSocialPath.child("friends").setValue([curUser.uniqueID:curUser.handle])
        let notify = Notification(id: curUser.uniqueID, handle: curUser.handle, note: "became friends", type: 0)
        targetSocialPath.child("notifications").childByAutoId().setValue(notification!.toDict())
        // delete our current notification
        ourSocialPath.child("notifications").child(key).setValue(nil)
        let indexPath = NSIndexPath(row: position, section: 0)

        notifications.removeValue(forKey: key)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
