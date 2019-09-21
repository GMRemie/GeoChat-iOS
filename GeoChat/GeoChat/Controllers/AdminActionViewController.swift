//
//  AdminActionViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class AdminActionViewController: UIViewController {

    var uniqueId:   String!
    var handle:     String!
    var reportID:   String!
    
    @IBOutlet weak var userHandleLbl: UILabel!
    
    @IBOutlet weak var banButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userHandleLbl.text = handle

       
        banCheck()
    }
    
    func banCheck(){
        print("Ban check")
        let userPath = Database.database().reference().child("users").child(self.uniqueId)
        userPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                let ban: Bool = snap["ban"] as? Bool ?? false
                print("Is it banned \(ban)")
                self.banButton.isEnabled = !ban
            }
        }
    }

    @IBAction func resetImage(_ sender: UIButton) {
        let storageRef = Storage.storage().reference().child(uniqueId)
        
        // Data in memory
        let data = UIImage(named: "login_forest")?.pngData()!
        
        // Create a reference to the file you want to upload
        let avatarRef = storageRef.child("avatar/avatar.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path
        let uploadTask = avatarRef.putData(data!, metadata: metadata) { (metadata, error) in
            
        }
        _ = uploadTask.observe(.success, handler: { (StorageTaskSnapshot) in
            print("Image has been succesfully uploaded!")
            let alert = UIAlertController(title: "Success!", message: "Users account has been succesfully created!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
                // Proceed to onboarding
            }))
            self.present(alert, animated: true)
        })
    }

    @IBAction func ban(_ sender: UIButton) {
        let alert = UIAlertController(title: "Ban", message: "Are you sure you want to ban this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ban", style: .destructive, handler: { (UIAlertAction) in
            let userPath = Database.database().reference().child("users").child(self.uniqueId)
            userPath.child("ban").setValue(true)
            sender.isEnabled = false
        }))
        self.present(alert, animated: true)
    }
    @IBAction func deleteUser(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete user", message: "Are you sure you want to delete this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
            let reportPath = Database.database().reference().child("reports").child(self.uniqueId)
            reportPath.setValue(nil)
            let userPath = Database.database().reference().child("users").child(self.uniqueId)
            userPath.setValue(nil)
            
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    
    

    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
