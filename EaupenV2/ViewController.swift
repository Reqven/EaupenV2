//
//  ViewController.swift
//  EaupenV2
//
//  Created by Manu Marchand on 15/02/2018.
//  Copyright © 2018 Manu Marchand. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RxSwift

class ViewController: UIViewController {
    
//    var amenities: [Amenity]? {
//        didSet { DispatchQueue.main.async(execute : { self.initData() }) }
//    }
    
    var amenities: [Amenity]? {
        didSet { DispatchQueue.main.async(execute: { self.initData() })
        }
    }
    
    let mapDidChange = PublishSubject<Bool>()
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    
    func locator(_ locator: Locator, didUpdateLocation location: CLLocation) {
        print("Location succeded")
        let alertController = UIAlertController(title: "Location succeded", message: "", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
        self.setupCoordinate(coordinate: location.coordinate)
//        self.setAmenities(coordinates: location.coordinate)
        return
    }
    
    func initData() {
        clearAnnotations()
        guard let amenities = self.amenities, amenities.count > 0 else {
            let alertController = UIAlertController(title: "Aucun point d'eau trouvé", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true)
            return
        }
        
        for amenity in amenities {
            if let annotation = Annotation.init(amenity: amenity) {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func setupCoordinate(coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async(execute: {
            let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 2000.0)
            self.mapView.setCamera(camera, animated: false)
        })
        
//        _ = AmenityService.shared.amenities(coordinate: coordinate)
//            .observeOn(MainScheduler.instance)
//            .take(1)
//            .subscribe(onNext: { amenities in
//                self.amenities = amenities
//            }, onError: { error in
//                print("Error: \(error.localizedDescription)")
//            })
    }
    
    func reloadAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        if let annotations = amenities?.flatMap(Annotation.init) {
            mapView.addAnnotations(annotations)
        }
    }
    
    func clearAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setAmenities(coordinates: CLLocationCoordinate2D(latitude: 48.831034, longitude: 2.355265))
        self.setupCoordinate(coordinate: CLLocationCoordinate2D(latitude: 48.831034, longitude: 2.355265))
//        mapView.showsUserLocation = true
        
        mapDidChange
            .map({ _ in self.mapView.centerCoordinate})
            .flatMap(AmenityService.shared.amenities)
            .subscribe(onNext: { amenities in
                self.amenities = amenities
                self.initData()
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func localizeAction(_ sender: Any) {
        _ = Locator.shared.locationSubject
            .take(1)
            .subscribe(onNext: { location in
                self.setupCoordinate(coordinate: location.coordinate)
                self.saveUserLocation(coordinate: location.coordinate)
            })
        self.clearAnnotations()
        Locator.shared.start()
    }
    
    func saveUserLocation(coordinate: CLLocationCoordinate2D) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "userLocationExists")
        defaults.set(coordinate.latitude, forKey: "latitude")
        defaults.set(coordinate.longitude, forKey: "longitude")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showAmenity", let amenity = sender as? Amenity else { return }
        
        let controller = segue.destination as! AmenityViewController
        controller.amenity = amenity
    }
    
}
    
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotations: MKAnnotation) -> MKAnnotationView? {
        
        switch annotations {
            
        case is MKUserLocation:
            return nil
        
        case is Annotation:
            //let view = MKPinAnnotationView(annotation: annotations, reuseIdentifier: nil)
            let view = MKAnnotationView(annotation: annotations, reuseIdentifier: nil)
            view.image = #imageLiteral(resourceName: "water")
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
            
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard
            control == view.rightCalloutAccessoryView,
            let annotation = view.annotation as? Annotation
        else { return }
        
        let amenity = annotation.amenity
        self.performSegue(withIdentifier: "showAmenity", sender: amenity)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapDidChange.onNext(animated)
    }
}


