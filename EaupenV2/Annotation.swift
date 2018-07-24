//
//  Annotation.swift
//  EaupenV2
//
//  Created by Manu Marchand on 15/02/2018.
//  Copyright © 2018 Manu Marchand. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    let amenity: Amenity
    var title: String?
    
    init?(amenity: Amenity) {
        guard let loc = amenity.loc, let lat = loc.lat, let lon = loc.lon else { return nil }
        
        self.amenity = amenity
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.title = amenity.display_name
        super.init()
    }
    
}
