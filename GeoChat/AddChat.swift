//
//  AddChat.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-01.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

protocol updateMap: class {
    func updateMap()
}

class AddChat: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ImageChangedDelegate {
    
    var delegate: updateMap?
    
    var imagePressed = ""
    
    let availablePrivacySettings = ["All In Range", "Only Friends", "Direct Message"]
    
    @IBOutlet weak var privacySettingsTextField: UITextField!
    
    let privacyPicker = UIPickerView()
    
    var Location: CLLocation? = nil
    
    @IBOutlet weak var display_image: UIButton!
    
    
    @IBOutlet weak var titleText: UITextField!
    
    func userChangedImage(imageString: String?) {
        print(imageString)
        imagePressed = imageString!
        display_image.setImage(UIImage(named:imagePressed), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privacySettingsTextField.inputView = privacyPicker
        privacyPicker.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func showImageSelection(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "Image_Selection") as! ImageCollectionView
        vc1.delegate = self
        self.show(vc1,sender:nil)
    }
    
    
    @IBAction func createButton(_ sender: Any) {
        //SEND INFO TO SERVER
        //SEGUE TO CHAT
        if (titleText.text! != "" && Location != nil) {
            CreateChat()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availablePrivacySettings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availablePrivacySettings.count
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        privacySettingsTextField.text = availablePrivacySettings[row]
    }
    
    func CreateChat () {
        let parameters: Parameters=[
            "Name":titleText.text!,
            "Username":UserDefaults.standard.object(forKey: "Username")!,
            "Longitude":Location!.coordinate.longitude,
            "Latitude":Location!.coordinate.latitude,
            "Private":privacySettingsTextField.text!,
            "Image":imagePressed
        ]
        let URL_USER_CREATE_CHAT = AppDelegate.URLConnection + "/CreateChat"
        Alamofire.request(URL_USER_CREATE_CHAT, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        //let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        //let vc = mainStoryboard.instantiateViewController(withIdentifier: "Map") as! MapView
                        //self.present(vc, animated: true, completion: nil)
                        self.delegate?.updateMap()
                        //self.dismiss(animated: false, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }

}
