//
//  Amenity.swift
//  EaupenV2
//
//  Created by Manu Marchand on 15/02/2018.
//  Copyright © 2018 Manu Marchand. All rights reserved.
//

import UIKit

class Amenity: Decodable {
    
    var _id: String?
    var source: String?
    var licence: String?
    var name: String?
    var amenity: String?
    var updated: Int?
    var point_type: String?
    var loc: Location?
    var postal_address: PostalAddress?
    var dist: Double?
    var display_name: String {
        guard let address = postal_address?.address else {
            return ""
        }
        return address
    }
    
    var description: String {
        guard let lat = loc?.lat, let lon = loc?.lon else {
            return "No location"
        }
        return "lat: \(lat), lon: \(lon)"
    }
    
}

