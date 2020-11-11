//
//  SecondViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 15/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class ExperienceViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var flippedImage: UIImage?
    
    
//    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeHandler()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()

        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
    }

//    Such that when people return, it reloads.
    override func viewWillAppear(_ animated: Bool) {
        startRunningCaptureSession()
    }
    
    
    @objc func doubleTapped() {
        switchCamera()
    }
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    
    @objc func switchCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentCamera?.position == AVCaptureDevice.Position.back) ? frontCamera : backCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentCamera = newDevice
        captureSession.commitConfiguration()
    }
    
////    POSSIBILITY TO ZOOM
//    @objc func zoomIn() {
//        if let zoomFactor = currentCamera?.videoZoomFactor {
//            if zoomFactor < 5.0 {
//                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
//                do {
//                    try currentCamera?.lockForConfiguration()
//                    currentCamera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
//                    currentCamera?.unlockForConfiguration()
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
//
//    @objc func zoomOut() {
//        if let zoomFactor = currentCamera?.videoZoomFactor {
//            if zoomFactor > 1.0 {
//                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
//                do {
//                    try currentCamera?.lockForConfiguration()
//                    currentCamera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
//                    currentCamera?.unlockForConfiguration()
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
    
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    @IBAction func takePhoto(_ sender: Any) {

        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func swipeHandler(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
    
        upSwipe.direction = .down
        downSwipe.direction = .up
        leftSwipe.direction = .left
        rightSwipe.direction = .right
    
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.view.addGestureRecognizer(downSwipe)
        self.view.addGestureRecognizer(upSwipe)
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
        
        if sender.direction == .up {
//            switchCamera()
        }
        
        if sender.direction == .down {
//            switchCamera()
        }
    }
    
//    Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)
          
//        if let image_download = UIImage(data: imageData) {
//           let photo:Data = image_download.sd_imageData(as: SDImageFormat.webP)!
//            image = UIImage(data: photo)
//            }
             
            if currentCamera == frontCamera {
                let srcImage = image
                    image = UIImage(cgImage: (srcImage?.cgImage!)!, scale: srcImage!.scale, orientation: UIImage.Orientation.leftMirrored)
            }
            
            performSegue(withIdentifier: "fromCameraToPreview", sender: nil)
           }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromCameraToPreview" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }

}

