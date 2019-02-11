//
//  LoginRegister.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit

class LoginRegister: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isKeyPresentInUserDefaults(key:"Username") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(vc, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
