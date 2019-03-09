//
//  FirstViewController.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

class MapView: UIViewController, CLLocationManagerDelegate, MapsDelegate {
    
    func updateMap() {
        addRadiusCircle(location: locValue!)
    }
    
    func didDisconnect() {
        addChatButton.isEnabled = false
    }
    
    func didConnect() {
        addChatButton.isEnabled = true
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var locValue: CLLocation? = nil
    @IBOutlet weak var addChatButton: UIButton!
    var circ: GMSCircle? = nil
    var radius = 1000.00
    typealias Marker = (ID:String,Marker:GMSMarker)
    var Markers:[Marker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            //mapView.settings.myLocationButton = true
        }
        addChatButton.layer.shadowColor = UIColor(hex: 0x000000, a: 0.5).cgColor
        addChatButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addChatButton.layer.shadowRadius = 5
        addChatButton.layer.shadowOpacity = 1.0
        TabBarController.MapDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        if (locValue != nil) {
            addRadiusCircle(location: locValue!)
        }
        if (!TabBarController.socket.isConnected) {
            TabBarController.socket.connect()
        } else {
            addChatButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if (UserDefaults.standard.object(forKey: "radius") != nil) {
            radius = UserDefaults.standard.double(forKey: "radius")
        } else {
            UserDefaults.standard.set(1000.00,forKey:"radius")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    @IBAction func addChat(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "AddChat") as! AddChat
        vc1.Location = locValue
        self.show(vc1,sender:nil)
    }
    
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        } else {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locValue == nil) {
            circ = GMSCircle(position: manager.location!.coordinate, radius: radius)
            self.locationChanged(location: manager.location!)
        } else {
            let distanceInMeters = manager.location?.distance(from: locValue!)
            if (distanceInMeters! > Double(100)) {
                self.locationChanged(location: manager.location!)
            }
        }
    }
    
    func locationChanged(location:CLLocation){
        locValue = location
        TabBarController.location = locValue
        mapView.camera = GMSCameraPosition(target: locValue!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        UpdateLocationFunction(Location: (location))
        self.addRadiusCircle(location:(location))
    }
    
    func addRadiusCircle(location: CLLocation){
        circ!.position = location.coordinate
        circ!.radius = radius
        circ!.fillColor = UIColor(hex: 0xFFDC00, a: 0.1)
        circ!.strokeColor = UIColor(hex: 0xFFDC00, a: 1)
        circ!.strokeWidth = 4
        circ!.map = mapView
        GetChats(location: location.coordinate)
    }

    func UpdateLocationFunction (Location: CLLocation) {
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
            "Longitude":Location.coordinate.longitude,
            "Latitude":Location.coordinate.latitude
        ]
        let URL_USER_UPDATE_LOCATION = AppDelegate.URLConnection + "/UpdateLocation"
        Alamofire.request(URL_USER_UPDATE_LOCATION, method: .post, parameters: parameters).responseJSON
        {
            response in
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    print("Successful")
                    let JSONString = "{\"Type\": 0,\"Data\":{\"User\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")! )\",\"Longitude\":\"\(Location.coordinate.longitude)\",\"Latitude\":\"\(Location.coordinate.latitude)\",\"Radius\":\"\(Float(UserDefaults.standard.double(forKey: "radius")))\"}}}"
                    TabBarController.socket.write(string: JSONString)
                }else{
                    print("Unsuccessful")
                }
            }
        }
    }

    func GetChats(location: CLLocationCoordinate2D) {
        TabBarController.local_chats = []
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
            "Longitude":location.longitude,
            "Latitude":location.latitude,
            "Radius":UserDefaults.standard.double(forKey: "radius")
        ]
        let URL_USER_UPDATE_LOCATION = AppDelegate.URLConnection + "/GetMapChats"
        Alamofire.request(URL_USER_UPDATE_LOCATION, method: .post, parameters: parameters).responseJSON
        {
            response in
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                    self.MakeMarkers(array1: array)
                    TabBarController.local_chats = array
                }else{
                    print("Unsuccessful")
                    self.MakeMarkers(array1:nil)
                }
            }
        }
    }
    
    func MakeMarkers(array1:[NSDictionary]?) {
        var local_markers:[Marker] = []
        if let array = array1 {
            array.forEach({
                let coord = CLLocation(latitude: $0.value(forKey: "Latitude") as! Double, longitude: $0.value(forKey: "Longitude") as! Double).coordinate
                let image = ($0.value(forKey: "Image") as! String)
                let title = ($0.value(forKey: "chat_name") as! String)
                let marker = GMSMarker(position: coord)
                let pinImage = UIImage(named:image)
                marker.title = title
                marker.icon = pinImage
                let marker1 = Marker($0.value(forKey:"chat_id") as! String,marker)
                local_markers.append(marker1)
            })
        }
        self.AddMarkers(markers:local_markers)
    }
    
    func AddMarkers(markers:[Marker]){
        print(self.Markers)
        print(markers)
        markers.forEach { (arg0) in
            
            let (ID, Marker) = arg0
            if (!MapContains(a: self.Markers, v: (ID,Marker))){
                Marker.map = self.mapView
                self.Markers.append(arg0)
            }
        }
        for i in self.Markers.enumerated().reversed(){
            let (index,element) = i
            if (!MapContains(a:markers, v:element)) {
                print(index)
                element.Marker.map = nil
                self.Markers.remove(at: index)
            }
        }
        print(self.Markers.count)
    }
    
    func MapContains(a:[(String, GMSMarker)], v:(String,GMSMarker)) -> Bool {
        let (c1, _) = v
        for (v1, _) in a { if v1 == c1 { return true } }
        return false
    }
    
    func GetSubscribed() {
        TabBarController.subscribed = []
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
        ]
        let URL_USER_GET_SUBSCRIBED = AppDelegate.URLConnection + "/GetSubscribedChats"
        Alamofire.request(URL_USER_GET_SUBSCRIBED, method: .post, parameters: parameters).responseJSON
            {
                response in
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        TabBarController.subscribed = array
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
}


extension UIColor {
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF),
            green: CGFloat((hex >> 8) & 0xFF),
            blue: CGFloat(hex & 0xFF),
            alpha: a
        )
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

