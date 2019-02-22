//
//  ColorPicker_1Sample.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-18.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit

class colorPicker_1Sample: UIViewController {
    
    
    
    @IBOutlet weak var colorPicker: UIImageView!
    
    @IBOutlet weak var colorPicked: UIView!
    
    @IBOutlet weak var colorPrevious: UIView!
    
    @IBOutlet weak var darknessText: UITextField!
    
    
    @IBOutlet weak var darknessSlider: UISlider!
    
    @IBOutlet weak var redSlider: UISlider!
    
    @IBOutlet weak var redText: UITextField!
    
    @IBOutlet weak var greenSlider: UISlider!
    
    @IBOutlet weak var greenText: UITextField!
    
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var blueText: UITextField!
    
    var setting:String? = nil
    
    
    var colorSelected:UIColor? = nil
    
    
    @IBAction func revert(_ sender: Any) {
        colorSelected = colorPrevious.backgroundColor
        colorChosen()
    }
    
    
    @IBAction func Finish(_ sender: Any) {
        if (setting != nil) {
            UserDefaults.standard.set(colorPicked.backgroundColor?.toHex(), forKey: setting!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func darknessChanged(_ sender: Any) {
        darknessText.text = String(format: "%.02f",Double(darknessSlider.value))
        colorChanged()
    }
    
    @IBAction func redChanged(_ sender: Any) {
        redText.text = String(format: "%.02f",Double(redSlider.value))
        colorChanged()
    }
    
    @IBAction func greenChanged(_ sender: Any) {
        greenText.text = String(format: "%.02f",Double(greenSlider.value))
        colorChanged()
    }
    
    @IBAction func blueChanged(_ sender: Any) {
        blueText.text = String(format: "%.02f",Double(blueSlider.value))
        colorChanged()
    }
    
    func colorChanged() {
        colorSelected = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1)
        let color = colorSelected?.adjustBrightness(brightnessBy: CGFloat(darknessSlider.value))
        colorPicked.backgroundColor = color
    }
    
    func colorChosen() {
        colorPicked.backgroundColor = uiColorFromHex(rgbValue: colorSelected!.toHex())
        darknessSlider.value = 1.0
        darknessText.text = String(format: "%.02f",Double(darknessSlider.value))
        redSlider.value = Float((colorSelected?.getRed())!)
        redText.text = String(format: "%.02f",Double(redSlider.value))
        greenSlider.value = Float((colorSelected?.getGreen())!)
        greenText.text = String(format: "%.02f",Double(greenSlider.value))
        blueSlider.value = Float((colorSelected?.getBlue())!)
        blueText.text = String(format: "%.02f",Double(blueSlider.value))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.layer.borderWidth = 1.0
        colorPicker.layer.masksToBounds = false
        colorPicker.layer.borderColor = UIColor.white.cgColor
        colorPicker.layer.cornerRadius = colorPicker.frame.size.width / 2
        colorPicker.clipsToBounds = true
        if (UserDefaults.standard.object(forKey: setting!) != nil) {
            colorSelected = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: setting!))
            colorPrevious.backgroundColor = colorSelected
            colorChosen()
        }
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (getColorTapped(sender:)))
        self.colorPicker.addGestureRecognizer(gesture)
    }
    
    @objc func getColorTapped(sender:UITapGestureRecognizer) {
        let point = sender.location(in: sender.view)
        print("Tapped")
        //For example take reference Color
        colorSelected  = getPixelColorAtPoint(point: point, sourceView: colorPicker)
        colorChosen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func getPixelColorAtPoint(point:CGPoint, sourceView: UIView) -> UIColor
    {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        sourceView.layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        pixel.deallocate()
        return color
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
extension UIColor {
    func toHex() -> Int {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return rgb
    }
    
    func getRed() -> CGFloat {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        //let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return r
    }
    
    func getGreen() -> CGFloat {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        //let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return g
    }
    
    func getBlue() -> CGFloat {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        //let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return b
    }
    
    public func adjustBrightness(brightnessBy brightness: CGFloat = 0) -> UIColor {
        
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0
        
        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue,
                           saturation: currentSaturation,
                           brightness: brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
    
    public func getBrightness() -> CGFloat {
        
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0
        
        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return currentBrigthness
        } else {
            return 0.0
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
}
