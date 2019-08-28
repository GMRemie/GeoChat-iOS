//
//  RegistrationViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker:UIImagePickerController!
    
    var path:DatabaseReference!
    
    var customProfilePicture = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Round our buttons corners
        signupButton.roundCorners()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        
        path = Database.database().reference()
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func uploadPhoto(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        self.present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        //Fix this later
        customProfilePicture = true
        
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    

    @IBAction func signupClicked(_ sender: UIButton) {
        let handle = usernameText.text
        let email = emailText.text
        let password = passwordText.text
        
        let handles = path.child("handles")
        handles.observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.hasChild(handle!){
                let alert = UIAlertController(title: "Error", message: "Handle is already taken!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert, animated: true)
            }else{
                
                Auth.auth().createUser(withEmail: email!, password: password!) { (AuthDataResult, Error) in
                    if (Error != nil) {
                        let alert = UIAlertController.init(title: "Error", message: "There was an error creating your account!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default))
                        self.present(alert, animated: true)
                        
                        print("GeoChat Error occured! \(Error!)")
                    }
                    
                    // Should be no error. Should be good to go
                    let user = AuthDataResult!.user
                    
                    // Update our handles array
                    self.path.child("handles").child(handle!).setValue(user.uid)
                    
                    // Update our user account
                    self.path.child("users").child(user.uid).child("handle").setValue(handle!)
                    
                    // Upload our profile picture!
                    // Create a root reference
                    let storageRef = Storage.storage().reference().child(user.uid)
                    
                    // Data in memory
                    let data = self.imageView.image!.jpegData(compressionQuality: 0.5)!
                    
                    // Create a reference to the file you want to upload
                    let avatarRef = storageRef.child("avatar/avatar.jpg")
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    // Upload the file to the path "images/rivers.jpg"
                    let uploadTask = avatarRef.putData(data, metadata: metadata) { (metadata, error) in
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            print("Error occured")
                            return
                        }
                    }
                    let successObserver = uploadTask.observe(.success, handler: { (StorageTaskSnapshot) in
                        print("Image has been succesfully uploaded!")
                        let alert = UIAlertController(title: "Success!", message: "Your account has been succesfully created!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
                            // Proceed to onboarding
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                    })
                    
                }
                
            }
        }
    
 
    }
}