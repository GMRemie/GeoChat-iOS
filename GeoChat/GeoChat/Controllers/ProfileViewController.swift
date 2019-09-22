//
//  ProfileViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/9/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
import Charts

class ProfileViewController: UIViewController {
    
    
    var userInfo: User!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var userBio: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    var sent = [String:String]()
    var received = [String:String]()
    var friends = [String:String]()
    
    @IBOutlet weak var followingLabel: UIButton!
    
    @IBOutlet weak var followersLabel: UIButton!
    
    @IBOutlet weak var photosCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        handleLabel.text = "@\(userInfo!.handle!)"
        profilePicture.image = userInfo.avatar

        photosCount.text = "0"
        
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        loadBio()
 
        
        let curUser = Auth.auth().currentUser!
        let dbRef = Database.database().reference()
        let main = dbRef.child("users").child(curUser.uid).child("social")
        main.observe(.value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                self.updateFriends(data: data)
            }
        }

    }
    
    func updatePieChart(){
        
        var followerCount:Double = (Double(received.count)) + 10
        var followingCount:Double = (Double(sent.count)) + 10
        var followers = PieChartDataEntry(value: followerCount)
        var following = PieChartDataEntry(value: followingCount)
        let dataEntries = [followers,following]

        followers.label = "Follower"
        following.label = "Following"
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [Colors.blue, Colors.salmon]
        chartDataSet.colors = colors as! [NSUIColor]
        
        pieChart.data = chartData
        
        
    }
    
    func updateFriends(data:NSDictionary){
        print("Updating friends..")
        
        sent.removeAll()
        received.removeAll()
        friends.removeAll()
        
        // Our Following, Followers, and friends
        let dict = data as! [String:Any]
        for (k,v) in dict{
            

            switch k{
            case "following":
                for (handle,id) in v as! [String:String]{
                    sent[id] = handle
                }
                
                break
            case "follower":
                for (handle,id) in v as! [String:String]{
                    received[id] = handle
                }
                break
                
            default:
                // friends
                break
            }
            
        }
        
        followingLabel.setTitle("\(sent.count)", for: .normal)
        followersLabel.setTitle("\(received.count)", for: .normal)

        updatePieChart()
    }

    
    func loadBio(){
        let dataRef = Database.database().reference()
        userInfo.getBio(ref: dataRef, label: userBio)
    }
    
    
    @IBAction func signoutClicked(_ sender: UIButton) {
        
        if Auth.auth().currentUser != nil{
            let confirm = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirm.addAction(UIAlertAction(title: "Log out", style: .default, handler: { (UIAlertAction) in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                self.performSegue(withIdentifier: "signOut", sender: self)
            }))
            
            self.present(confirm, animated: true)
            
        }
        
    }
    
    // user profile pages
    

    @IBAction func peoplesClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewPeople", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserResultsViewController{
            
            
            var resultA = friends.merging(received, uniquingKeysWith: { (first, _) in first })
            resultA = resultA.merging(sent, uniquingKeysWith: { (first, _) in first })
            
            destination.curUser = userInfo
            destination.header = "\(userInfo!.handle!)'s people"
            destination.people = resultA
        }
    }
}
