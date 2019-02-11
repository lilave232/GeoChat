//
//  Register.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Register: UIViewController {
    
    
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var ConfirmPassword: UITextField!
    let URL_USER_REGISTER = AppDelegate.URLConnection + ":8081/Register"
    let defaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround() 
    }
    
    @IBAction func Register(_ sender: Any) {
        if (ConfirmPassword.text == Password.text)
        {
            RegisterFunction(Username: Username.text ?? "", Password: Password.text ?? "")
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height*0.5)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func RegisterFunction (Username: String, Password: String) {
        //creating parameters for the post request
        let parameters: Parameters=[
            "Username":Username,
            "Password":Password,
        ]
        
        //Sending http post request
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    
                    //if there is no error message sent set user defaults
                    if ((jsonData.value(forKey: "error") as! Bool?)! == false) {
                        //set userdefaults for firstname
                        //set userdefaults for username
                        self.defaultValues.set(Username, forKey: "Username")
                        // set userdefaults for password
                        self.defaultValues.set(Password, forKey: "Password")
                        //set userdefaults for token
                        //change from entrance to TabBarController
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let vc : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        //if error display alert so that user knows creation failed
                        print("Unsuccessful")
                    }
                }
        }
    }
    
}
