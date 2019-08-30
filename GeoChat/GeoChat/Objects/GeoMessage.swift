//
//  GeoMessage.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import MapKit


class GeoMessage: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var author: String?
    var caption: String?
    var url: String?
    var lat: Double
    var long:Double
    var id: String
    
    init(title:String,lat:Double,long:Double,author:String, caption:String?,url:String?, id:String){
        self.title = title
        self.author = author
        self.lat = lat
        self.long = long
        self.caption = caption
        self.url = url
        self.id = id
        coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
        super.init()
    }
    func convertToDict() -> [String:Any] {
        var dict = [String:Any]()
        dict["title"] = self.title!
        dict["author"] = self.author!
        dict["lat"] = self.lat
        dict["long"] = self.long
        dict["caption"] = self.caption!
        dict["url"] = self.url!
        dict["id"] = self.id
        
        return dict
    }

}
