//
//  CreateBizPostViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import StoreKit
import Lottie

class CreateBizPostViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    // ui elements
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var expControl: UISegmentedControl!
    @IBOutlet weak var sendButton: UIButton!
    
    var profile:User!
    
    var imagePicker:UIImagePickerController!
    
    var path:DatabaseReference!
    
    var coordinates: CLLocationCoordinate2D!
    var animationView: AnimationView!
    var blurEffectView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.layer.cornerRadius = 17
        sendButton.roundCorners()
        path = Database.database().reference()
        IAPService.shared.BizCreator = self
        IAPService.shared.getProducts()

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

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // actions
    
    @IBAction func imagePickerClicked(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        
        switch expControl.selectedSegmentIndex {
        case 0:
            //
        IAPService.shared.purchase(product: IAPProduct.weekly)
            break
        case 1:
            IAPService.shared.purchase(product: IAPProduct.monthly)
            break
        case 2:
            IAPService.shared.purchase(product: IAPProduct.yearly)
            break
        default:
            
            
            break
        }
        
        
    }
    
    func businessMarkerCallBack(){
        startAnimation()
        let caption = captionField.text!
        
        let storageRef = Storage.storage().reference().child(profile.uniqueID).child(caption)
        
        // Data in memory
        let data = self.imageView.image!.jpegData(compressionQuality: 0.5)!
        
        // Create a reference to the file you want to upload
        let avatarRef = storageRef.child("photo/photo.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = avatarRef.putData(data, metadata: metadata) { (StorageMetadata, Error) in
            if (Error != nil){
                self.stopAnimation()
                print("Error uploading file")
            }
        }
        let successObserver = uploadTask.observe(.success) { (StorageTaskSnapshot) in
            // good to go
            avatarRef.downloadURL(completion: { (durl, Error) in
                if (Error != nil){
                    self.stopAnimation()
                    print("Error")
                }else{
                    let generator = UUID()
                    let uuid = generator.uuidString
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateStyle = DateFormatter.Style.short
                    dateformatter.timeStyle = DateFormatter.Style.short
                    let now = dateformatter.string(from: Date())
                    
                    // Successfully got download URL
                    let geoMessage = GeoMessage(title: "@\(self.profile!.handle!)", lat: self.coordinates.latitude, long: self.coordinates.longitude, author: self.profile.uniqueID, caption: caption, url: durl?.absoluteString, id: uuid, privacy: false, biz: true, date:now,exp:self.expControl.selectedSegmentIndex)
                   
                    
                    
                    self.path.child("public").child(uuid).setValue(geoMessage.convertToDict(), withCompletionBlock: { (Error, DatabaseReference) in
                        self.stopAnimation()
                        if (Error != nil){
                            print("Error uploading GeoChat message to database")
                        }
                        
                        let alert = UIAlertController(title: "Message posted", message: "Your Business message has been posted publicly!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
                            self.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true)
                    })
                    
                }
            })
        }
        
    }

}
