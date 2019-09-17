//
//  Report.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/12/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation


struct Report : Encodable {
    let reportedID: String
    let reporterID: String
    let date: Date
    let reason: String

    
    
    
}
