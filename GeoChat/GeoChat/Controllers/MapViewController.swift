//
//  MapViewController.swift
//  GeoChat
//
//  Created by Joseph Storer on 8/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var mapkit: MKMapView!
    @IBOutlet weak var bizButton: UIButton!
    
    var Profile:User!
    var BusinessAccount = false
    let locationmanager = CLLocationManager()
    
    var path:DatabaseReference!
    var discovered = [String]()
    var messages = [String:GeoMessage]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapkit.mapType = .mutedStandard
        
        BusinessAccount = Profile.bizAccount
        
        createButton.backgroundColor = Colors.yellow
        createButton.layer.cornerRadius = 40
        
        if (BusinessAccount){
            bizButton.backgroundColor = Colors.yellow
            bizButton.layer.cornerRadius = 40
            bizButton.isHidden = false
        }else{
            bizButton.isHidden = true
        }
        
        checkLocationServices()
        
        path = Database.database().reference()
        loadOurMessages()
        
    }
    
    func setupLocationManager(){
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Business Marker
    
    @IBAction func bizMarkerClick(_ sender: UIButton) {
        let option = UIAlertController(title: "Business Manager", message: "What would you like to do?", preferredStyle: .alert)
        option.addAction(UIAlertAction(title: "Marker Stats", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "markerStats", sender: self)
        }))
        option.addAction(UIAlertAction(title: "Create Marker", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "createBizMarker", sender: self)
        }))
        self.present(option, animated: true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreatePostViewController {
            destination.profile = Profile
            destination.coordinates = locationmanager.location?.coordinate
        }
        if let destination = segue.destination as? CreateBizPostViewController{
            destination.profile = Profile
            destination.coordinates = locationmanager.location?.coordinate
        }
        
        if let destination = segue.destination as? MessageViewController{
            let msgData = sender as! MessageContainer
            destination.msg = msgData
            destination.currentUser = Profile
        }
        if let destination = segue.destination as? MarkerStatsViewController{
            destination.owner = Profile
        }
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
    
    func loadOurMessages(){
        
        let userPath = path.child("users").child(Profile.uniqueID).child("discovered")
        let publicPath = path.child("public")
        
        userPath.observe(.value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                for (key,values) in snap{
                    let k: String = key as! String
                    self.discovered.append(k)
                }
            }
        }
        
        // clear old cached messages
        
        for region in locationmanager.monitoredRegions {
            locationmanager.stopMonitoring(for: region)
        }
        
        
        // Load messages
        publicPath.observe(.value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                for (key,values) in snap {
                    let newValues = values as! NSDictionary
                    let author = newValues["author"] as! String
                    let caption = newValues["caption"] as! String
                    let lat = newValues["lat"] as! Double
                    let long = newValues["long"] as! Double
                    let title = newValues["title"] as! String
                    let url = newValues["url"] as! String
                    let k:String = key as! String
                    let privacy = newValues["privacy"] as! Bool
                    let date = newValues["date"] as! String
                    var biz = false
                    var exp = newValues["exp"] as! Int
                    guard let bizCheck = newValues["biz"] as? Bool else{
                        biz = false
                        return
                    }
                    biz = bizCheck
                    
                    if (privacy){
                        guard let users = newValues["users"] as? [String:String] else{
                            return
                        }
                        let msg = GeoMessage(title: title, lat: lat, long: long, author: author, caption: caption, url: url, id: k,privacy:false, biz: biz, date: date,exp:exp)
                        msg.users = users
                        self.messages[k] = msg
                        if (self.discovered.contains(k)){
                            // already discovered
                        }else{
                            if (author != self.Profile.uniqueID){
                                // Make sure we are a target user!
                                if ((msg.users?.keys.contains(self.Profile.uniqueID))!){
                                    self.monitorAndRegisterMessage(msg: msg)
                                }
                            }
                        }
                    }else{
                        let msg = GeoMessage(title: title, lat: lat, long: long, author: author, caption: caption, url: url, id: k,privacy:false, biz: biz,date:date,exp:exp)
                        self.messages[k] = msg
                        if (self.discovered.contains(k)){
                            // not discovered
                        }else{
                            if (author != self.Profile.uniqueID){
                                // Possibly a business message that expire
                                if (msg.biz){
                                    // Check expiration date
                                    let dateformatter = DateFormatter()
                                    dateformatter.dateStyle = DateFormatter.Style.short
                                    dateformatter.timeStyle = DateFormatter.Style.short
                                    let posted = dateformatter.date(from: date)
                                    let totalDays = Date().days(sinceDate:posted!)
                                    switch msg.exp{
                                    case 0:
                                        if (totalDays! < 7){
                                            self.monitorAndRegisterMessage(msg: msg)
                                        }
                                        break
                                    case 1:
                                        if (totalDays! < 30){
                                            self.monitorAndRegisterMessage(msg: msg)
                                        }
                                        break
                                    case 2:
                                        if (totalDays! < 365){
                                            self.monitorAndRegisterMessage(msg: msg)
                                        }
                                        break
                                    default:
                                        // do nothing
                                        break
                                    }
                                }else{
                                    self.monitorAndRegisterMessage(msg: msg)
                                }
                            }
                        }

                    }
                }
            }
        }
        
        
        
        
        
    }
    
    
    func monitorAndRegisterMessage(msg:GeoMessage){
        // change to always later
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
             // Register
                let maxDistance = locationmanager.maximumRegionMonitoringDistance
                let region = CLCircularRegion(center: msg.coordinate, radius: 100, identifier: msg.id)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                let circle = MKCircle(center: msg.coordinate, radius: 100)
               
                mapkit.addOverlay(circle)
                mapkit.addAnnotation(msg)
                
                
                locationmanager.startMonitoring(for: region)
            }
        }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationmanager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            mapkit.setRegion(region, animated: true)
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
            locationmanager.requestAlwaysAuthorization()
            // asking for permission
        case .restricted:
            // notify user permission is restricted parentlal
            break
        case .authorizedAlways:
            // app can be minimized or background
            mapkit.showsUserLocation = true
            centerViewOnUserLocation()
            locationmanager.startUpdatingLocation()
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("You just entered a region! You found it! \(region.identifier)")
            let found = UIAlertController(title: "Message found!", message: "You found a new message! Would you like to open it?", preferredStyle: .alert)
            found.addAction(UIAlertAction(title: "No", style: .destructive))
            found.addAction(UIAlertAction(title: "Open", style: .default, handler: { (UIAlertAction) in
                self.discoverMessage(identifier: region.identifier, region: region)
            }))
            present(found, animated: true)
    }
    
    func discoverMessage(identifier:String, region: CLRegion){
        let msg:GeoMessage = messages[identifier]!

        let userPath = path.child("users").child(msg.author!)
        
        userPath.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let snap = DataSnapshot.value as? NSDictionary{
                let handle = snap["handle"] as! String
                let msgContainer = MessageContainer.init(msg: msg, handle: handle)
                if (!msg.biz){
                    let userPath = self.path.child("users").child(self.Profile.uniqueID).child("discovered")

                    userPath.child(msgContainer.msg.id).setValue("Discovered")
                
                    self.locationmanager.stopMonitoring(for: region)
                    
                    for mark in self.mapkit.annotations{
                        if (mark.coordinate.latitude == msgContainer.msg.coordinate.latitude && mark.coordinate.longitude == msgContainer.msg.coordinate.longitude){
                            self.mapkit.removeAnnotation(mark)
                        }
                    }
                    
                    for overlay in self.mapkit.overlays{
                        if (overlay.coordinate.latitude == msgContainer.msg.coordinate.latitude && overlay.coordinate.longitude == msgContainer.msg.coordinate.longitude){
                            self.mapkit.removeOverlay(overlay)
                        }
                    }
                    self.performSegue(withIdentifier: "viewMessage", sender: msgContainer)

                }else{
                    // Update business marker discovery count
                    let bizMarkerPath = self.path.child("public").child(identifier).child("discoveries")
                    bizMarkerPath.childByAutoId().setValue(self.Profile.uniqueID)
                    self.performSegue(withIdentifier: "viewMessage", sender: msgContainer)
                }
            }
        }
        
        
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapkit.setRegion(region, animated: true)
        //later
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuth()
        // later
    }
    
    
    
    
    // this is where we will customize our marker for Business markers
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = Colors.blue
        circleRenderer.fillColor = Colors.bottom_blue
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? GeoMessage else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    
    }
    
    
    
}
