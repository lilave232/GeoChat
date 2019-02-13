//
//  chatSettings.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-11.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit


class ColorPicker: UIViewController {
    
    // RRGGBB hex colors in the same order as the image
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    
    var setting:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.object(forKey: setting!) != nil) {
            slider.value = Float(colorArray.firstIndex(where: { $0 == UserDefaults.standard.integer(forKey: setting!)})!) + 0.5
            selectedColorView.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: setting!))
        }
    }
    
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBAction func sliderChanged(sender: AnyObject) {
        selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
        if (setting != nil) {
            UserDefaults.standard.set(colorArray[Int(slider.value)], forKey: setting!)
        }
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
