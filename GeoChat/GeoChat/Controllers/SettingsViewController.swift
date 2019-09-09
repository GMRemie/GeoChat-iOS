//
//  SettingsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bioText: UITextField!
    @IBOutlet weak var handleText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    var imagePicker:UIImagePickerController!
    var path:DatabaseReference!
    var changedPic = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 64
        saveButton.roundCorners()
        
        
        uploadButton.layer.cornerRadius = uploadButton.bounds.height/2
        
        path = Database.database().reference()
        loadOriginalInformation()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func loadOriginalInformation(){
        let curUser = Auth.auth().currentUser!
        let userPath = self.path.child("users").child(curUser.uid)
        
        // Text field values
        let bio = bioText.text!
        let handle = handleText.text!
        let email = emailText.text!
        let password = passwordText.text!
        
        let storage = Storage.storage().reference()
        let storageRef = storage.child(curUser.uid)
        let avatarRef = storageRef.child("avatar/avatar.jpg")
        
        // get handle and other user information later on in beta states
        let userInfoPath = self.path.child("users").child(curUser.uid)
        var userHandle: String!
        userInfoPath.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                userHandle = snap["handle"] as! String
                self.handleText.text = userHandle
                if let bio = snap["bio"] as? String {
                    print("error")
                    self.bioText.text = bio
                }
                self.emailText.text = curUser.email!
                
            }
        })
        
        avatarRef.downloadURL(completion: { (iURL, Error) in
            if (Error != nil){
                print("ERror downloading url")
            }else{
                let config = URLSessionConfiguration.default
                let session = URLSession.init(configuration: config)
                
                let task = session.dataTask(with: iURL!, completionHandler: { (Data, Response, Error) in
                    if (Error != nil){
                        print("error")
                        return
                    }
                    guard let response = Response as? HTTPURLResponse, response.statusCode == 200 else{
                        print("Error")
                        return
                    }
                    
                    let img = UIImage(data: Data!)
                    DispatchQueue.main.async {
                        self.imageView.image = img!
                    }
                })
                task.resume()
             
            }
        })
       
        
        
    }
    

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let curUser = Auth.auth().currentUser!
        let userPath = self.path.child("users").child(curUser.uid)
        
        
        
        // Text field values
        let bio = bioText.text!
        let handle = handleText.text!
        let email = emailText.text!
        let password = passwordText.text!
        
        // Handle bio
        if bio.count > 0 {
            userPath.child("bio").setValue(bio)
        }
        
        if password.count > 0 {
            if (password.count < 6){
                let alert = UIAlertController(title: "Error!", message: "Password must be 6 characters long", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                present(alert, animated: true)
            }else{
                curUser.updatePassword(to: password)
            }
        }
        

       
        if email.count > 0 {
            if (validateEmail(enteredEmail: emailText.text!)){
                Auth.auth().currentUser?.updateEmail(to: emailText.text!)
            }else{
                let alert = UIAlertController(title: "Error!", message: "Poorly formatted email!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                present(alert, animated: true)
            }
            
        }
        if handle.count > 0 {
            let handles = path.child("handles")
            handles.observeSingleEvent(of: .value) { (DataSnapshot) in
                if DataSnapshot.hasChild(handle){
                    let alert = UIAlertController(title: "Error", message: "Handle is already taken!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default))
                    self.present(alert, animated: true)
                }else{
                    userPath.child("handle").setValue(handle)
                    self.path.child("handles").child(handle).setValue(curUser.uid)
                }
            }
        }
        if changedPic {
            let storageRef = Storage.storage().reference().child(curUser.uid)
            
            // Data in memory
            let data = self.imageView.image!.jpegData(compressionQuality: 0.5)!
            
            // Create a reference to the file you want to upload
            let avatarRef = storageRef.child("avatar/avatar.jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = avatarRef.putData(data, metadata: metadata) { (metadata, error) in
                
            }
            _ = uploadTask.observe(.success, handler: { (StorageTaskSnapshot) in
                print("Image has been succesfully uploaded!")

            })
        }
        
        let alert = UIAlertController(title: "Success!", message: "Your account information has been updated!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        self.present(alert, animated: true)
        
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    @IBAction func uploadButton(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        changedPic = true
        //Fix this later
        
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardWillChange(up: true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        keyboardWillChange(up: false)
        
    }
    
    // Keyboard pushing up
    
    func keyboardWillChange(up:Bool){
        
        if (up){
            view.frame.origin.y = -240
            
        }else{
            view.frame.origin.y = 0
        }
    }
}
