//
//  ReportDetailsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase


class ReportDetailsViewController: UIViewController {

    var DatabaseRef: DatabaseReference!
    var reportID: String!
    var report: Report!
    var adminView: AdminReportsViewController!
    
    // UI elements
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var reportedName: UITextField!
    @IBOutlet weak var reporterName: UITextField!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var totalReportsLbl: UILabel!
    @IBOutlet weak var userLogsBtn: UIButton!
    @IBOutlet weak var userControlBtn: UIButton!
    @IBOutlet weak var resolvedBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseRef = Database.database().reference()
        // Update our Date
        
        dateLbl.text = report.date
        detailsLbl.text = report.reason
        
        // get the handle of our Reporter
        
        UIDToHandle(uid: report.reportedID, label: reportedName, reported: true)
        UIDToHandle(uid: report.reporterID, label: reporterName, reported: false)
        
        
    }
    
    func UIDToHandle(uid:String,label:UITextField, reported: Bool){
        
        let userRef = DatabaseRef.child("users").child(uid)
        userRef.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                label.text = snap["handle"] as! String
                if (reported){
                    let userreportCount = snap["reports"] as! NSDictionary
                    self.totalReportsLbl.text = "Total Reports: \(userreportCount.count)"
                }
            }
        }
    }
    


    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AdminLogViewController{
            destination.handle = self.reportedName.text!
            destination.userUID = self.report.reportedID
        }
        if let destination = segue.destination as? AdminActionViewController{
            destination.handle = self.reportedName.text
            destination.uniqueId = self.report.reportedID
        }
    }
    
    
    @IBAction func userLogsClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "log", sender: self)
    }
    
    @IBAction func userControlClick(_ sender: UIButton) {
    }
    
    
    @IBAction func resolvedClick(_ sender: UIButton) {
        let reportRef = DatabaseRef.child("reports").child(report.reportedID).child(reportID)
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to mark this report as resolved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Resolve", style: .default, handler: { (UIAlertAction) in
            reportRef.removeValue()
            self.resolvedBtn.isHidden = true
            self.dateLbl.text = "RESOLVED - \(Date())"
        }))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
