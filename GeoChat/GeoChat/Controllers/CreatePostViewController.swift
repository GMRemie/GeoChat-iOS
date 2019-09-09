//
//  CreatePostViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreatePostViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    
    @IBOutlet weak var selectImage: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    @IBOutlet weak var captionText: UITextField!
    
    var profile:User!
    
    var imagePicker:UIImagePickerController!
    
    var path:DatabaseReference!
    
    var coordinates: CLLocationCoordinate2D!
    
    
    @IBOutlet weak var publicSwitch: UISwitch!
    
    @IBOutlet weak var privateMessageDetails: UIView!
    
    @IBOutlet weak var addUserButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectImage.layer.cornerRadius = 17
        sendButton.roundCorners()
        
        addUserButton.roundCorners()
        addUserButton.layer.borderColor = Colors.blue.cgColor

        path = Database.database().reference()
        
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func uploadClicked(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    

    @IBAction func sendClicked(_ sender: UIButton) {
        
        let caption = captionText.text!
        
        
        let storageRef = Storage.storage().reference().child(profile.uniqueID).child(caption)
        
        // Data in memory
        let data = self.imageView.image!.jpegData(compressionQuality: 0.5)!
        
        // Create a reference to the file you want to upload
        let avatarRef = storageRef.child("photo/photo.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = avatarRef.putData(data, metadata: metadata) { (StorageMetadata, Error) in
            if (Error != nil){
                print("Error uploading file")
            }
        }
        let successObserver = uploadTask.observe(.success) { (StorageTaskSnapshot) in
            // good to go
            avatarRef.downloadURL(completion: { (durl, Error) in
                if (Error != nil){
                    print("Error")
                }else{
                    let generator = UUID()
                    let uuid = generator.uuidString
                    
                    // Successfully got download URL
                    let geoMessage = GeoMessage(title: "New Message", lat: self.coordinates.latitude, long: self.coordinates.longitude, author: self.profile.uniqueID, caption: caption, url: durl?.absoluteString, id: uuid)
                    

                    self.path.child("public").child(uuid).setValue(geoMessage.convertToDict(), withCompletionBlock: { (Error, DatabaseReference) in
                        if (Error != nil){
                            print("Error uploading GeoChat message to database")
                        }
                        
                        let alert = UIAlertController(title: "Message posted", message: "Your message has been posted publicly!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
                            self.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true)
                    })
                    
                }
            })
        }
        
        
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    
    @IBAction func switchClicked(_ sender: UISwitch) {
        if(sender.isOn){
            // public message
            privateMessageDetails.isHidden = true
            
        }else{
            // Private message
            privateMessageDetails.isHidden = false
        }
    }
    
    
    @IBAction func addUserClicked(_ sender: UIButton) {
        // This is called when the user tries ading people to the receipt list
    }
}
