//
//  AmenityService.swift
//  EaupenV2
//
//  Created by Manu Marchand on 04/04/2018.
//  Copyright © 2018 Manu Marchand. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import RxSwift

class AmenityService {
    
    static var shared = AmenityService()
    
    func amenities(coordinate: CLLocationCoordinate2D) -> Observable <[Amenity]> {
        return Observable.create({ observer in
            
            let headers = [
                "Accept" : "application/json"
            ]
            
            let urlParams = [
                "lat": coordinate.latitude,
                "lon": coordinate.longitude,
                "limit" : 50,
                "range" : 1600
            ]
            
            Alamofire.request("http://api.eaupen.net/closest", method : .get, parameters : urlParams, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch(response.result) {
                    case .success :
                        if let data = response.data,
                            let amenities = try? JSONDecoder().decode([Amenity].self, from: data) {
                            
                            observer.onNext(amenities)
                        } else {
                            observer.onNext([])
                        }
                        
                    case .failure(let error) :
                        print("HTTP FAILURE : \(error.localizedDescription)")
                    }
                    
            }
            
            return Disposables.create()
            })
    }

}
