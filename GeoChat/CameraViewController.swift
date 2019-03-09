//
//  CameraViewController.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-03-07.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var camInt: Int = 0
    var photoOutput:AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?

    
    @IBAction func dismissButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        if (camInt == 0) {
            camInt = 1
        } else {
            camInt = 0
        }
        captureSession.stopRunning()
        captureSession.removeInput(captureSession.inputs[0])
        captureSession.removeOutput(captureSession.outputs[0])
        setupDevice(cameraPosition: camInt)
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(cameraPosition:Int = 0) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        if (cameraPosition == 0)
        {
            currentCamera = backCamera
        } else {
            currentCamera = frontCamera
        }
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    @IBOutlet weak var cameraView: UIView!
    
    
    func setupPreviewLayer() {
        if (cameraPreviewLayer != nil)
        {
            cameraPreviewLayer?.removeFromSuperlayer()
            cameraPreviewLayer = nil
        }
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspect
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.cameraView.frame
        self.cameraView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        //self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        //performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error:Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            if (currentCamera?.position == AVCaptureDevice.Position.front)
            {
                var flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: .leftMirrored)
                image = flippedImage
            }
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "CameraPreview") as! CameraPreviewController
            vc1.image = image
            self.show(vc1,sender:nil)
        }
    }
}
