//
//  AdminReportsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class AdminReportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var admin: User!
    var ReportRef: DatabaseReference!
    var reports = [String:Report]()
    var selectedReportKey: String!
    var selectedReport: Report!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadReports()
    }
    
    func loadReports(){
        ReportRef = Database.database().reference().child("reports")
        ReportRef.observe(.value) { (DataSnapshot) in
            self.tableView.reloadData()
            self.reports.removeAll()
            if let snap = DataSnapshot.value as? NSDictionary{
                print("Should call")
                self.refreshReports(data: snap)
                
            }
        }
    }
    
    
    func refreshReports(data: NSDictionary){

        // cycling through users UIDs for reports
        for (k,v) in data{
            // K is the users UID
            // V is the report dictionary with K of that as the report ID
            let reportsDict = v as! NSDictionary
            for (reportID, reportDetails) in reportsDict{
                let reportraw = reportDetails as! NSDictionary
                let reason = reportraw["reason"] as! String
                let reporterID = reportraw["reporterID"] as! String
                let reportedID = reportraw["reportedID"] as! String
                let date = reportraw["date"] as! String
                let reportobj = Report.init(reportedID: reportedID, reporterID: reporterID, date: date, reason: reason)
                let reportID = reportID as! String
                self.reports[reportID] = reportobj
                
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AdminReportCellTableViewCell
        
        let key = Array(reports.keys)[indexPath.row]
        let report = reports[key]
        
        cell.timeLbl.text = report!.date
        cell.reportLbl.text = "#\(key)"
        cell.handleLbl.text = "ID: Loading.."

        // We need to receive our users handle based on their ID so setup observe method for each and call away
        let userPath = Database.database().reference().child("users").child(report!.reportedID)
        userPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                let handle = snap["handle"] as! String
                cell.handleLbl.text = "ID: \(handle)"
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(reports.keys)[indexPath.row]
        let report = reports[key]
        
        selectedReportKey = key
        selectedReport = report!
        
        self.performSegue(withIdentifier: "details", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReportDetailsViewController{
            destination.reportID = selectedReportKey
            destination.report = selectedReport
            destination.adminView = self
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    

    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
}
