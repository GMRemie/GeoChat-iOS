//
//  UserResultsViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class UserResultsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {

    var users = [User]()
    var results = [User]()

    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (results.count > 0){
            return results.count
        }else{
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        return cell!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Search feature
        self.sortUsers(input: textField.text!)
        
        return true
    }
    
    func sortUsers(input: String){
        results.removeAll()
        results = users.filter({
            $0.handle.range(of: input.lowercased(), options: .caseInsensitive) != nil
        })
        
        self.tableView.reloadData()
    }
}
