//
//  User.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import UIKit

class User{
    
    let email: String!
    let uniqueID: String!
    let handle: String!
    let avatar: UIImage?
    
    init(_email:String,_id:String,_handle:String,_avatar:UIImage?) {
        self.email = _email
        self.uniqueID = _id
        self.handle = _handle
        self.avatar = _avatar
    }
    
}
