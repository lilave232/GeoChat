//
//  ImageCollectionView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-01.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ImageChangedDelegate {
    //Replace parameter with DeliveryDestinations
    func userChangedImage(imageString: String?)
}

class ImageCollectionView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: ImageChangedDelegate?
    
    let images = ["Blue","Dark_Blue", "Dark_Green", "Light_Green", "Pink", "Purple", "Red" ,"Yellow","Orange"]
    var text_to_send = ""
    var Location: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = self.delegate {
            print(delegate)
            //delegate.changeValue(testValue)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionCell
        cell.image.image = UIImage(named: "\(images[indexPath.row])_Location_Marker")
        // Configure the cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //vc1.imagePressed = "\(images[indexPath.row])_Location_Marker"
        //vc1.text_receive_string = text_to_send
        //vc1.Location = Location
        if let delegate = self.delegate {
            delegate.userChangedImage(imageString: "\(images[indexPath.row])_Location_Marker")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
