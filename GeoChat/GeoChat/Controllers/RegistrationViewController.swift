//
//  RegistrationViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker:UIImagePickerController!
    
    @IBOutlet weak var bizSwitch: UISwitch!
    
    @IBOutlet weak var pickImage: UIButton!
    
    var path:DatabaseReference!
    
    
    var customProfilePicture = false
    
    // lottie and animation
    
    var animationView: AnimationView!
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide lottie view by default
        
        // Round our buttons corners
        signupButton.roundCorners()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        
        path = Database.database().reference()
        
        pickImage.layer.cornerRadius = pickImage.bounds.height/2
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
    
    @IBAction func bizInfo(_ sender: UIButton) {
        
        let info = UIAlertController(title: "Business Account", message: "A business account is the same as a regular account. Business accounts have the option to purchase premium business markers that everyone can see.", preferredStyle: .alert)
        info.addAction(UIAlertAction(title: "Continue", style: .default))
        self.present(info, animated: true)
    }
    
    
    func startAnimation(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        animationView = AnimationView(name: "locationLottie")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 700)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        animationView.play()
        animationView.loopMode = .loop
    }
    
    func stopAnimation(){
        blurEffectView.isHidden = true
        animationView.isHidden = true
        
    }

    @IBAction func signupClicked(_ sender: UIButton) {
        
        startAnimation()
        
        let handle = usernameText.text
        let email = emailText.text
        let password = passwordText.text
        
        if (email?.count == 0 || password?.count == 0 || handle?.count == 0){
            print("Empty")
            stopAnimation()
            return
        }
        
        let handles = path.child("handles")
        handles.observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.hasChild(handle!){
                self.stopAnimation()
                let alert = UIAlertController(title: "Error", message: "Handle is already taken!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .default))
                self.present(alert, animated: true)
            }else{
                
                // So handle is available at this point
                
                Auth.auth().createUser(withEmail: email!, password: password!) { (AuthDataResult, Error) in
                    // This isnt catching error appropriately
                    if (Error != nil) {
                        self.stopAnimation()
                        let alert = UIAlertController.init(title: "Error", message: Error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default))
                        self.present(alert, animated: true)
                        
                        print("GeoChat Error occured! \(Error!)")
                        return
                    }
                    
                    // Should be no error. Should be good to go
                    let user = AuthDataResult!.user
                    
                    // Update our handles array
                    self.path.child("handles").child(handle!).setValue(user.uid)
                    
                    // Update our user account
                    self.path.child("users").child(user.uid).child("handle").setValue(handle!)
                    
                    // Update our business account status
                    self.path.child("users").child(user.uid).child("business").setValue(self.bizSwitch.isOn)
                    
                    // Upload our profile picture!
                    // Create a root reference
                    let storageRef = Storage.storage().reference().child(user.uid)
                    
                    // Data in memory
                    let data = self.imageView.image!.jpegData(compressionQuality: 0.5)!
                    
                    // Create a reference to the file you want to upload
                    let avatarRef = storageRef.child("avatar/avatar.jpg")
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    // Upload the file to the path
                    let uploadTask = avatarRef.putData(data, metadata: metadata) { (metadata, error) in
 
                    }
                    _ = uploadTask.observe(.success, handler: { (StorageTaskSnapshot) in
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
