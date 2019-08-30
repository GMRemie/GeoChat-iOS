//
//  MessageContainer.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import UIKit

struct MessageContainer{
    var msg:GeoMessage!
    var handle: String!
    
    func getCaption() -> String{
        return msg.caption!
    }
    func getImageUrl() -> String{
        return msg.url!
    }
    
    func getImage(image: UIImageView){
        let url = URL(string: msg.url!)
        let config = URLSessionConfiguration.default
        let session = URLSession.init(configuration: config)
        
        let task = session.dataTask(with: url!) { (Data, Response, Error) in
            if (Error != nil) {
                print(Error.debugDescription)
                return
            }
            
            guard let response = Response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error negative response")
                return
            }
            
            let loaded = UIImage(data: Data!)
            image.image = loaded
        }
        task.resume()
    }
    
}
