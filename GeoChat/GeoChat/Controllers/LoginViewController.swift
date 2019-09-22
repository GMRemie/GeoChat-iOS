//
//  LoginViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    var path:DatabaseReference!

    var selectedUserProfile: User!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize button
        signupButton.roundCorners()
        
        path = Database.database().reference()

    }
    
    
    @IBAction func signupClicked(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (AuthDataResult, Error) in
            if (Error != nil){
                let alert = UIAlertController(title: "Error!", message: Error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert, animated: true)
            }
            
            if (AuthDataResult?.user != nil){
                
                let aUser = AuthDataResult!.user
                
                print("Signed in succesfully \(aUser.uid)")
                let storage = Storage.storage().reference()
                let storageRef = storage.child(aUser.uid)
                let avatarRef = storageRef.child("avatar/avatar.jpg")
                
                // get handle and other user information later on in beta states
                
             
                
                let userInfoPath = self.path.child("users").child(aUser.uid)
                var userHandle: String!
                var bizAccount: Bool?
                var administrator: Bool?
                var ban: Bool?
                userInfoPath.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    if let snap = DataSnapshot.value as? NSDictionary{
                        userHandle = (snap["handle"] as! String)
                        
                        ban = snap["ban"] as? Bool ?? false
                        guard let biz = snap["business"] as? Bool else{
                            return
                        }

                        bizAccount = biz
                        
                        guard let admincheck = snap["administrator"] as? Bool else{
                            return
                        }
                        administrator = admincheck
                    }
                })
                
                if (ban != nil && ban == true){
                    let alert = UIAlertController(title: "BANNED", message: "You are banned from using GeoChat", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .destructive))
                    self.present(alert, animated: true)
                    
                    
                    
                    
                }else{
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
                                
                                let avatar = UIImage(data: Data!, scale: 0.5)
                                let currentUser = User(_email: Auth.auth().currentUser!.email!, _id: Auth.auth().currentUser!.uid, _handle: userHandle, _avatar: avatar)
                                if (bizAccount != nil){
                                    currentUser.bizAccount = bizAccount!
                                }
                                if (administrator != nil){
                                    currentUser.administrator = administrator!
                                }
                                self.selectedUserProfile = currentUser
                                print("Loaded information, proceeding to segue")
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "SignIn", sender: self)
                                }
                                
                            })
                            task.resume()
                        }
                    })
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let destination = (segue.destination as? UITabBarController)?.viewControllers!.first! as? MapViewController{
            destination.Profile = selectedUserProfile
        
        }
        
        if let destination = (segue.destination as? UITabBarController)?.viewControllers![2] as? ProfileViewController{
            destination.userInfo = selectedUserProfile
        }
        
        if let destination = (segue.destination as? UITabBarController)?.viewControllers![1] as? SearchViewController{
            destination.curUser = selectedUserProfile
        }
        
        if let destination = (segue.destination as? UITabBarController)?.viewControllers![3] as? NotificationViewController{
            destination.curUser = selectedUserProfile
        }
        //if let destinations = (segue.destination as! UITabBarController).viewControllers!.first! as? MapViewController{

      //  }
    
        
    }

    
}
