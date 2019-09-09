//
//  SearchViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/7/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase


class SearchViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource {

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var handlesStorage = [String:String]()
    var results = [User]()
    
    var selectedUser: User!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        searchBar.endEditing(true)
        searchFirebase(handle: searchBar.text!)
    }
    
    
    func searchFirebase(handle:String){
        handlesStorage.removeAll()
        results.removeAll()
        let reference = Database.database().reference()
        let handles = reference.child("handles")
        handles.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? NSDictionary{
                for (key,value) in data{
                    self.handlesStorage[key as! String] = value as! String
                }
                // Now filter
                let sortedStorage = self.handlesStorage.filter({$0.key.lowercased().contains(handle.lowercased())})
                self.processResultsToUsers(dict: sortedStorage)
            }
        }
 
    }

    func processResultsToUsers(dict:[String:String]){
        print("Processing")
        let reference = Database.database().reference()
        for (k,v) in dict{
            let path = reference.child("users").child(v)
            path.observeSingleEvent(of: .value) { (DataSnapshot) in
                if let data = DataSnapshot.value as? NSDictionary{
                    let resultUser = User(_email: "empty", _id: v, _handle: k, _avatar: nil)
                    self.results.append(resultUser)
                    if (self.results.count == dict.count){
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(results.count)
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultTableViewCell
        let info = results[indexPath.row]
        cell.handle.text = "@\(results[indexPath.row].handle!)"
        //self.results[indexPath.row].getAvatFromUID(id: info.uniqueID, image: cell.imageView!)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = results[indexPath.row]
        print(selectedUser.handle)
       performSegue(withIdentifier: "displayUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PublicProfileViewController{
            destination.userInfo = selectedUser
        }
    }

}
