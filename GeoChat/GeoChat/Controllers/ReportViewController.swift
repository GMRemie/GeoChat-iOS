//
//  ReportViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/12/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class ReportViewController: UIViewController {
    
    var reported: User!
    var reporter: User!
    var DatabaseReference: DatabaseReference!
    
    // UI elements
    @IBOutlet weak var reportedHandle: UILabel!
    
    @IBOutlet weak var reportReason: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseReference = Database.database().reference()
        
        reportedHandle.text = "@\(reported.handle!)"
        
    }


    @IBAction func reportSent(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to report this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (UIAlertAction) in
            // report here
            
            // Submit report
            
            let reportRef = self.DatabaseReference.child("reports").child(self.reported.uniqueID).childByAutoId()
            
            let report = Report(reportedID: self.reported.uniqueID, reporterID: self.reporter.uniqueID, date: Date(), reason: self.reportReason.text)
            do{
            try reportRef.setValue(report.asDictionary())
            } catch{
                print("Error")
            }
            
            
            
            
            // Update users total reports
            
            let reportedUserProfile = self.DatabaseReference.child("users").child(self.reported.uniqueID).child("reports").childByAutoId()
            do{
                try reportedUserProfile.setValue(report.asDictionary())
            } catch{
                print("Error")
            }
            
            self.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true)
        
        
        
    }
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
