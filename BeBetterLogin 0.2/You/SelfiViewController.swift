//
//  CameraViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 01/06/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import SDWebImage

class SelfiViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var flippedImage: UIImage?
    
    var databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference().child("Users")
    let userID = Auth.auth().currentUser!.uid
    
//    For name
    var serverTime = Timestamp.init().seconds
    let BebetterLong: Int64 = 3650000000000000
    var profileImageName: Int64 = 0
    var profileImageNameString = ""
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        profileImageName = BebetterLong - serverTime
        profileImageNameString = String(profileImageName)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//        tap.numberOfTapsRequired = 2
//        view.addGestureRecognizer(tap)
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
        
        currentCamera = frontCamera
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
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }

    func uploadImages(){
        
//        FULL SCREEN IMAGES.
//        Location on firebase.
        let fullHD = self.storageRef.child(userID).child("Images").child(profileImageNameString)
        
//        Resolution of image.
        let fullScreenImage = self.image!.resized(toWidth: 720)
        
//        Image turned into data, such that it can be uploaded.
        let fullHDCompressed = fullScreenImage?.sd_imageData(as: SDImageFormat.webP)
        let uploadTaskFullHD = fullHD.putData(fullHDCompressed!)
        uploadTaskFullHD.observe(.success) { snapshot in
          fullHD.downloadURL { (url, error) in
          if let ImageUrl = url?.absoluteString{
           
             self.databaseRef.child("Users").child(self.userID).child("image").setValue(ImageUrl)
            
        //    For FullScreen
        let fullHDArray: [String: Any] = [
            "timestamp": ServerValue.timestamp(),
            "profile" : ImageUrl ]
            self.databaseRef.child("Users").child(self.userID).child("profile").child(self.profileImageNameString).setValue(fullHDArray)
                }
            }
        }

        //        Thumbnail
        let thumbnail = self.storageRef.child(userID).child("Images").child(profileImageNameString + "_thumbnail")
        let thumbnailImage = self.image!.resized(toWidth: 75)
        let thumbnailImageCompressed = thumbnailImage?.sd_imageData(as: SDImageFormat.webP)
        let uploadTaskThumbnail = thumbnail.putData(thumbnailImageCompressed!)
        uploadTaskThumbnail.observe(.success) { snapshot in
          // Upload completed successfully
            thumbnail.downloadURL { (url, error) in
            if let ImageUrl = url?.absoluteString{

            self.databaseRef.child("Users").child(self.userID).child("image_thumbnail").setValue(ImageUrl)
                
            let thumbnailArray: [String: Any] = [
                "timestamp": ServerValue.timestamp(),
                "profile_thumbnail" : ImageUrl ]
                self.databaseRef.child("Users").child(self.userID).child("profile_thumbnail").child(self.profileImageNameString + "_thumbnail").setValue(thumbnailArray)
                }
            }
        }
    }

     @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

//    Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)
            if currentCamera == frontCamera {
                let srcImage = image
                    image = UIImage(cgImage: (srcImage?.cgImage!)!, scale: srcImage!.scale, orientation: UIImage.Orientation.leftMirrored)
            }
            
//            Upload Image in background.
            DispatchQueue.global().async {
                self.uploadImages()
            }
            
            performSegue(withIdentifier: "fromSelfiToYou", sender: nil)
           }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TabBarViewController
        vc.nextViewNumber = 4
    }
}

