//
//  FirebaseHelper.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseHelper {
    
    func handleAvailable(_ handle: String ) -> Bool {
        
        let path = Database.database().reference().child("handles")
        var available: Bool = false
        path.observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.hasChild(handle) {
                print("has remie")
                available = false
            }else{
                print("No remie")
                available = true
            }
        }
        return available
    }
    
}
