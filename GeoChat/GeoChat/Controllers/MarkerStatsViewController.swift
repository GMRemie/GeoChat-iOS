//
//  MarkerStatsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class MarkerStatsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    

    var owner: User!
    var DataRef: DatabaseReference!
    var messagePath: DatabaseReference!
    
    var businessMarkers = [GeoMessage]()
    var grossMarkers = [GeoMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataRef = Database.database().reference()
        messagePath = DataRef.child("public")

    }
    
    
    // Refresh Manually
    @IBAction func refreshClicked(_ sender: UIButton) {
        businessMarkers.removeAll()
        messagePath.observe(.value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                for (key,values) in snap {
                    let newValues = values as! NSDictionary
                    let author = newValues["author"] as! String
                    if (author == self.owner.uniqueID){
                        let caption = newValues["caption"] as! String
                        let lat = newValues["lat"] as! Double
                        let long = newValues["long"] as! Double
                        let title = newValues["title"] as! String
                        let url = newValues["url"] as! String
                        let date = newValues["date"] as! String
                        var biz = false
                        let exp = newValues["exp"] as! Int
                        guard let bizCheck = newValues["biz"] as? Bool else{
                            biz = false
                            return
                        }
                        biz = bizCheck
                        if (biz){
                            let message = GeoMessage(title: title, lat: lat, long: long, author: author, caption: caption, url: url, id: key as! String, privacy: false, biz: true, date: date, exp: exp)
                            self.businessMarkers.append(message)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // Parse Data
    

    
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessMarkers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell") as! StatsTableViewCell
        
        let message = businessMarkers[indexPath.row]
        
        // Is active?
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let posted = dateformatter.date(from: message.date)
        let totalDays = Date().days(sinceDate:posted!)
        // Expiration type
        var statusText      = ""
        var expirationText  = ""
        var discoveryText   = "Discoveries: 0"
        
        // Get marker discovery count
        
        // Update our discovery text for those that do not have any
        cell.discoveries.text = discoveryText

        
        let markerPath = DataRef.child("public").child(message.id).child("discoveries")
        markerPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                discoveryText = "Discoveries: \(snap.count)"
                cell.discoveries.text = discoveryText
            }
        }
        
        
        switch message.exp{
        case 0:
            if (totalDays! < 7){
                statusText = "Status: Active"
            }else{
                statusText = "Status: Expired"
            }
            expirationText = "Type: Weekly"
            break
        case 1:
            if (totalDays! < 30){
                statusText = "Status: Active"
            }else{
                statusText = "Status: Expired"
            }
            expirationText = "Type: Monthly"
            break
        case 2:
            if (totalDays! < 365){
                statusText = "Status: Active"
            }else{
                statusText = "Status: Expired"
            }
            expirationText = "Type: Yearly"
            break
        default:
            statusText = "Error!"
            expirationText = "Error!"
            break
        }
        
        
        
        cell.datePosted.text = message.date
        cell.statusLbl.text = statusText
        cell.expirationType.text = expirationText
        
        let config = URLSessionConfiguration.default
        let url = URL(string: message.url!)
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url!) { (data, response, Error) in
            if (Error != nil){
                print(Error!.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                print("Error response from URL")
                return
            }
            DispatchQueue.main.async {
                cell.imagesView.image = UIImage(data: data!)
            }
            
        }
        task.resume()
        

        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}
