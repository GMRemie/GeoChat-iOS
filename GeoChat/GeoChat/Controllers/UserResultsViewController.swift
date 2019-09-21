//
//  UserResultsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class UserResultsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {

    
    var people = [String:String]()
    var results = [String:String]()
    var header:String!
    var selectedUser: User!
    var curUser: User!
    
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        lblHeader.text = header
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (results.count != 0){
            return results.count
        }else{
            return people.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! UserResultTableViewCell
        let handle = Array(people.keys)[indexPath.row]
        let uid = people[handle]
        
        cell.handleLbl.text = handle
        
        // Avatar?
        let storage = Storage.storage().reference()
        let storageRef = storage.child(uid!)
        let avatarRef = storageRef.child("avatar/avatar.jpg")
        
        avatarRef.downloadURL { (url, Error) in
            if (Error != nil){
                print(Error?.localizedDescription)
                return
            }
            let configuration = URLSessionConfiguration.default
            let session = URLSession.init(configuration: configuration)
            let task = session.dataTask(with: url!, completionHandler: { (data, response, Error) in
                if (Error != nil){
                    print(Error?.localizedDescription)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                    print("Error")
                    return
                }
                DispatchQueue.main.async {
                    cell.profilePicture.image = UIImage(data: data!)
                }
            })
            task.resume()
        }
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Search feature
        self.sortUsers(input: textField.text!)
        
        return true
    }
    
    func sortUsers(input: String){
        if (input.count == 0){
            results = people
        }else{
            results.removeAll()
            results = people.filter({$0.key.range(of: input.lowercased(), options: .caseInsensitive) != nil})
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let handle = Array(people.keys)[indexPath.row]
        let uid = people[handle]
        selectedUser = User(_email: "blank", _id: uid!, _handle: handle, _avatar: nil)
        self.performSegue(withIdentifier: "displayUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PublicProfileViewController{
            destination.userInfo = selectedUser
            destination.curUser = curUser
        }
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
