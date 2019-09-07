//
//  SearchViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/7/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        print("Search button clicked \(searchBar.text!)")
        searchBar.endEditing(true)
    }

}
