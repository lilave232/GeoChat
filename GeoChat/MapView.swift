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
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var locValue: CLLocation? = nil
    //var circle: MKCircle? = nil
    @IBOutlet weak var addChatButton: UIButton!
    var circ: GMSCircle? = nil
    var controller: TabBarController? = nil
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
        controller = self.tabBarController as? TabBarController
        TabBarController.MapDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        if (locValue != nil) {
            addRadiusCircle(location: locValue!)
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
            //5
        } else {
            self.locationManager.requestAlwaysAuthorization()
            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locValue == nil) {
            locValue = manager.location
            TabBarController.location = locValue
            mapView.camera = GMSCameraPosition(target: locValue!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            UpdateLocationFunction(Location: (manager.location)!)
            self.addRadiusCircle(location:(manager.location)!)
        } else {
            let distanceInMeters = manager.location?.distance(from: locValue!)
            if (distanceInMeters! > Double(100)) {
                locValue = manager.location
                TabBarController.location = locValue
                mapView.camera = GMSCameraPosition(target: locValue!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                UpdateLocationFunction(Location: (manager.location)!)
                self.addRadiusCircle(location:(manager.location)!)
            }
        }
    }
    
    func addRadiusCircle(location: CLLocation){
        //mapView.clear()
        if (circ == nil) {
            circ = GMSCircle(position: location.coordinate, radius: radius)
            circ!.fillColor = UIColor(hex: 0xFFDC00, a: 0.1)
            circ!.strokeColor = UIColor(hex: 0xFFDC00, a: 1)
            circ!.strokeWidth = 4
            circ!.map = mapView
        } else {
            circ!.map = nil
            circ = GMSCircle(position: location.coordinate, radius: radius)
            circ!.fillColor = UIColor(hex: 0xFFDC00, a: 0.1)
            circ!.strokeColor = UIColor(hex: 0xFFDC00, a: 1)
            circ!.strokeWidth = 4
            circ!.map = mapView
        }
        //Get Chats
        GetChats(location: location.coordinate)
        //GetSubscribed()
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
        self.controller!.local_chats = []
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
                var local_markers:[Marker] = []
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                    array.forEach({
                        let coord = CLLocation(latitude: $0.value(forKey: "Latitude") as! Double, longitude: $0.value(forKey: "Longitude") as! Double).coordinate
                        let image = ($0.value(forKey: "Image") as! String)
                        let title = ($0.value(forKey: "chat_name") as! String)
                        let marker = GMSMarker(position: coord)
                        let pinImage = UIImage(named:image)
                        //let size = CGSize(width: width, height: height)
                        //UIGraphicsBeginImageContext(size)
                        //pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                        //let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                        marker.title = title
                        marker.icon = pinImage
                        //marker.map = self.mapView
                        let marker1 = Marker($0.value(forKey:"chat_id") as! String,marker)
                        local_markers.append(marker1)
                    })
                    self.controller!.local_chats = array
                }else{
                    print("Unsuccessful")
                }
                //print(local_markers)
                self.AddMarkers(markers:local_markers)
            }
        }
    }
    
    func AddMarkers(markers:[Marker]){
        markers.forEach { (arg0) in
            
            let (ID, Marker) = arg0
            if (!MapContains(a: self.Markers, v: (ID,Marker))){
                print("Adding Marker")
                Marker.map = self.mapView
                self.Markers.append(arg0)
            }
        }
        print(Markers)
        //print(self.markers)
        var deleted:[Int] = []
        for i in self.Markers.enumerated(){
            let (index,element) = i
            if (!MapContains(a:markers, v:element)) {
                print("Remove Marker")
                element.Marker.map = nil
                deleted.append(index)
            }
        }
        for i in deleted{
            self.Markers.remove(at: i)
        }
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
                        print("Checked Chats")
                        TabBarController.subscribed = array
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
    //MAPS API KEY AIzaSyCe1BfQ2Bdcb50fExIsxnGXgH9CzbbJ3nk
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

