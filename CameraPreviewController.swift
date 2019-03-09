//
//  CameraPreviewController.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-03-07.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit

protocol CameraPreviewProtocol {
    func getImage(image: UIImage)
}

class CameraPreviewController: UIViewController {
    
    var image: UIImage!
    static var delegate:CameraPreviewProtocol?
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        CameraPreviewController.delegate?.getImage(image: imageView.image!)
        self.navigationController?.popToRootViewController(animated: true)
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    
}
