//
//  Codable.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/12/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation

extension Encodable{
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
