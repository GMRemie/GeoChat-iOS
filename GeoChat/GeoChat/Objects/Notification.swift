//
//  Notification.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/7/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation


struct Notification{
    var userID: String
    var handle: String
    var note: String
    var type: Int
    
    init(id:String,handle:String,note:String,type:Int){
        self.userID = id
        self.handle = handle
        self.note = note
        self.type = type
    }
    
    func toDict()->[String:Any]{
        var dic = [String:Any]()
        
        dic["id"] = userID
        dic["handle"] = handle
        dic["note"] = note
        dic["type"] = type
        return dic
    }
    
    
}
