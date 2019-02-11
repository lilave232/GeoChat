//
//  Login.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Login: UIViewController {
    
    
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    let defaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround() 
    }
    
    @IBAction func Login(_ sender: Any) {
        LoginFunction(Username: Username.text ?? "", Password: Password.text ?? "")
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
    
    func LoginFunction (Username: String, Password: String) {
        //Set parameters to send to server
        let parameters: Parameters=[
            //set username value as username text field value
            "Username":Username,
            //set password value as password text field value
            "Password":Password,
            //set Token as value of unique device notification token
        ]
        let URL_USER_LOGIN = AppDelegate.URLConnection + ":8081/LogIn"
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    //if there is no error
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        
                        //getting the user from response
                        let user = jsonData.value(forKey: "user") as! NSDictionary
                        

                        let passWord = user.value(forKey: "Password") as! String
                        let userName = user.value(forKey: "Username") as! String
                        
                        self.defaultValues.set(passWord, forKey: "Password")
                        self.defaultValues.set(userName, forKey: "Username")
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let vc : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                        self.present(vc, animated: true, completion: nil)
                        //switching the screen
                    }else{
                        //error message in case of invalid credential
                        print("Unsuccessful")
                    }
                }
        }
    }
    
}
