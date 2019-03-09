//
//  Settings.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-22.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData
import AVFoundation
import Photos
import ImageIO
import SwiftyJSON

class ProfileSettings: UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, CameraPreviewProtocol {
    
    func getImage(image: UIImage) {
        setImage(image: image)
    }
    
    func setImage(image: UIImage) {
        profileImage.image = image
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documents URL: \(documentsURL)")
        let documentPath = documentsURL.path
        let filePath = documentsURL.appendingPathComponent("ProfileImage.png")
        do {
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
            for file in files {
                if "\(documentPath)/\(file)" == filePath.path {
                    try fileManager.removeItem(atPath: filePath.path)
                }
            }
        } catch {
            print("Could not add image: \(error)")
        }
        
        do {
            if let jpegImageData = image.jpegData(compressionQuality: 1) {
                try jpegImageData.write(to: filePath,options:.atomic)
                requestWith(imageData: jpegImageData, parameters: [:])
            }
        } catch {
            print("Could not write image: \(error)")
        }
        UserDefaults.standard.set(filePath, forKey: "ProfileImage")
    }
    
    @IBOutlet weak var UsernameLabel: UILabel!
    
    @IBOutlet weak var BackgroundColorButton: UIButton!
    
    var Friends:[String] = []
    var FriendsDB:[String] = []
    var FriendsOnline:[String] = []
    
    @IBOutlet weak var fullscreenLabel: UIButton!
    
    @IBOutlet weak var addFriendsLabel: UIButton!
    
    @IBOutlet weak var requestsLabel: UIButton!
    
    @IBOutlet weak var kilometersLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let DB = DBHandler()
    
    @IBAction func showFriendsView(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "FriendsView") as! FriendsTableView
        vc1.Friends = Friends
        self.show(vc1, sender:nil)
    }
    
    @IBAction func changeBackgroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! colorPicker_1Sample
        vc1.setting = "ColorBack"
        self.show(vc1, sender:nil)
    }
    
    @IBOutlet weak var kilometersSlider: UISlider!
    
    @IBAction func distanceChanged(_ sender: Any) {
        if (kilometersSlider.value > 1000) {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value/1000)) + "km"
        } else {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value)) + "m"
        }
        UserDefaults.standard.set(Double(kilometersSlider.value),forKey:"radius")
    }
    
    
    @IBAction func changeImage(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        //self.present(imagePicker, animated: true, completion: nil)
    }
    func openCamera(){
        CameraPreviewController.delegate = self
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "Camera") as! CameraViewController
        self.show(vc1,sender:nil)
    }
        
    func openGallary(){
        checkGalleryPermissions()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image Taken")
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //profileImage.image = pickedImage
            setImage(image: pickedImage)
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func checkGalleryPermissions() {
        PHPhotoLibrary.requestAuthorization { (status) in
            // No crash
        }
    }
    func checkCameraPermissions() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            } else {
                
            }
        }
    }
    
    
    @IBOutlet weak var ForegroundColorButton: UIButton!
    
    
    @IBAction func changeForegroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! colorPicker_1Sample
        vc1.setting = "ColorFront"
        self.show(vc1, sender: nil)
    }
    
    
    
    @IBOutlet weak var previewBackground: UIImageView!
    
    @IBOutlet weak var previewForeground: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 1.0
        profileImage.layer.borderColor = UIColor(red: 192, green: 192, blue: 192).cgColor
        if (UserDefaults.standard.object(forKey: "ProfileImage") != nil) {
            do {
                let imageData = try Data(contentsOf: UserDefaults.standard.url(forKey: "ProfileImage")!)
                profileImage.image = UIImage(data: imageData)
            } catch {
                print("Error loading image : \(error)")
            }
        }
        //deleteAllRecords(entity: "Friends")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.addObserver(self, selector: #selector(cameraChanged(notification:)), name: .AVCaptureSessionDidStartRunning, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        kilometersSlider.value = Float(UserDefaults.standard.double(forKey: "radius"))
        if (kilometersSlider.value > 1000) {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value/1000)) + "km"
        } else {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value)) + "m"
        }
        fullscreenLabel.titleLabel?.numberOfLines = 1
        fullscreenLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        fullscreenLabel.titleLabel?.minimumScaleFactor = 0.8
        
        addFriendsLabel.titleLabel?.numberOfLines = 1
        addFriendsLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        addFriendsLabel.titleLabel?.minimumScaleFactor = 0.8
        
        requestsLabel.titleLabel?.numberOfLines = 1
        requestsLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        requestsLabel.titleLabel?.minimumScaleFactor = 0.8
        
        
        UsernameLabel.text = UserDefaults.standard.string(forKey: "Username")
        FriendsDB = DB.GetFriendsFromDB()
        Friends = FriendsDB
        self.tableView.reloadData()
        GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
        let BubbleImage = UIImage(named: "Chat Bubble")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28),
                            resizingMode: .stretch)
        previewBackground.image = BubbleImage
        if (UserDefaults.standard.object(forKey: "ColorBack") != nil) {
            BackgroundColorButton.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorBack"))
            previewBackground.tintColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorBack"))
        }
        if (UserDefaults.standard.object(forKey: "ColorFront") != nil) {
            ForegroundColorButton.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorFront"))
            previewForeground.textColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorFront"))
        }

    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + "/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                self.FriendsOnline = []
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let requests = jsonData.value(forKey: "pending") as! Int
                        self.requestsLabel.setTitle("Requests(" + String(requests) + ")", for: .normal)
                        let array = jsonData.value(forKey: "values") as! [NSDictionary]
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.FriendsOnline.append(friend!)
                        })
                    }else{
                        let requests = 0
                        self.requestsLabel.setTitle("Requests(" + String(requests) + ")", for: .normal)
                        print("Error Or No Friends")
                    }
                    self.Friends = self.DB.adjustFriendsDB(Online: self.FriendsOnline,Database: self.FriendsDB)
                    self.tableView.reloadData()
                }
        }
    }
    
    func RemoveFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + "/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        self.GetFriends(Username: Username!)
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                }
        }
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func requestWith(imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let url = AppDelegate.URLConnection + "/ProfileImageUpload" /* your API url */
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "\(UserDefaults.standard.string(forKey: "Username") ?? "**^^**").jpeg", mimeType: "image/jpeg")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(nil)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
}
