//
//  InterfaceController.swift
//  GeoChatWatch Extension
//
//  Created by Joseph Storer on 9/26/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreLocation
import MapKit

class InterfaceController: WKInterfaceController,WCSessionDelegate, CLLocationManagerDelegate {
    
    var markers = [CLLocationCoordinate2D]()
    
    @IBOutlet weak var refreshButton: WKInterfaceButton!
    
    let locationManager:CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    @IBOutlet weak var mapVIew: WKInterfaceMap!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default:nil
    
    override init() {
        super.init()

        
        
    }
    
    func getMarkerData(){
        print("Getting marker data...")
        
        
    }
    
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received Message data!!")
    }
    
    @IBAction func refreshClicked() {
        if let session = session, session.isReachable{
            session.sendMessage(["refresh":true], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        markers.removeAll()
        for (_,v) in message{
            let raw = v as! String
            var values = raw.split(separator: "$")
            let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(values[0])!)!, longitude: CLLocationDegrees(exactly: Double(values[1])!)!)
            markers.append(coord)
            mapVIew.addAnnotation(coord, with: .red)
            
        }
        let coordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: 98.5795)

        
        mapVIew.addAnnotation(coordinate, with: .purple)

        
    }
    
    
    
    
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapVIew.setRegion(region)
    }
    
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            print("Checking services")
            setupLocationManager()
            checkLocationAuth()
            
            
        }else{
            // Alert here
            
        }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            mapVIew.setRegion(region)
        }
    }
    
    func checkLocationAuth(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            // only when app is open
            
            // add our thing here
            break
        case .denied:
            // tell user to enable permission
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        // asking for permission
        case .restricted:
            // notify user permission is restricted parentlal
            break
        case .authorizedAlways:
            // app can be minimized or background
            
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    session
    
    override func willActivate() {
        super.willActivate()
        checkLocationServices()
        
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }

        
        // Contact our iOS device if active, and get our data
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
