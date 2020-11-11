//
//  PreviewViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 25/05/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
//import FirebaseStorage
//import FirebaseDatabase
import Firebase
import SDWebImage

class MemoryPreviewViewController: UIViewController, UITextFieldDelegate {
    
    //UserID
    let userID = Auth.auth().currentUser!.uid

    //    Connect to server storage location.
    let storageRef = Storage.storage().reference()
    var databaseRef: DatabaseReference! = Database.database().reference()
    var serverTime = Timestamp.init().seconds
    let BebetterLong: Int64 = 3650000000000000
    var imageKey: Int64 = 0
    var imageKeyString = ""
    var experienceKey = ""
    
    
    var image: UIImage!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var descriptionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageKey = BebetterLong - serverTime
        imageKeyString = String(imageKey)
        
        HideKeyboard()
        photo.image = self.image
        
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
//        setUpExperience()
        performSegue(withIdentifier: "fromMemoryPreviewToFriendList", sender: nil)
    }

    @IBAction func nextFullScreenButton(_ sender: Any) {
//        setUpExperience()
        performSegue(withIdentifier: "fromMemoryPreviewToFriendList", sender: nil)
    }

    //    When clicking "return"/ "next" on keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        setUpExperience()
        performSegue(withIdentifier: "fromMemoryPreviewToFriendList", sender: nil)
        return false
    }
//    
//    func setUpExperience(){
//        
////        Updates timestamp for experience, which is nice so it comes up top in your memories.
//        databaseRef.child("Experiences").child(String(experienceKey)).child("timestamp").setValue(ServerValue.timestamp()){
//          (error:Error?, ref:DatabaseReference) in
//          if let error = error {
//            print("Data could not be saved: \(error).")
//          } else {
//            
////            Adds yourself to participation.
//            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("participants").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())
//
////            Upload description:
//            let description = self.descriptionTextField.text!
//            self.uploadImages()
// 
//                }
//            }
//        }
//    
//    func uploadImages(){
////        FULL SCREEN IMAGES.
////        Location on firebase.
//        
////        IF I change imageKeyString to experienceKey, I will override the image which has worked in the past to keep server use low.
//        let fullHD = self.storageRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.imageKeyString)
//        
////        Resolution of image.
//        let fullScreenImage = self.image.resized(toWidth: 720)
//        
////        Image turned into data, such that it can be uploaded.
//        let fullHDCompressed = fullScreenImage?.sd_imageData(as: SDImageFormat.webP)
//        let uploadTaskFullHD = fullHD.putData(fullHDCompressed!)
//        uploadTaskFullHD.observe(.success) { snapshot in
//          fullHD.downloadURL { (url, error) in
//          if let ImageUrl = url?.absoluteString{
//              let fullHDArray: [String: Any] = [
//                "timestamp": ServerValue.timestamp(),
//                  "from": self.userID,
//                  "description": self.descriptionTextField.text!,
//                  "image" : ImageUrl ]
//              self.databaseRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.imageKeyString).setValue(fullHDArray)
//                  }
//              }
//        }
//            
//        //        Feed Image
//        let feed = self.storageRef.child("Experiences").child(self.experienceKey).child("feed").child(self.imageKeyString)
//        let feedImage = self.image.resized(toWidth: 360)
//        let feedCompressed = feedImage?.sd_imageData(as: SDImageFormat.webP)
//        let uploadTaskFeed = feed.putData(feedCompressed!)
//        uploadTaskFeed.observe(.success) { snapshot in
//           // Upload completed successfully
//            feed.downloadURL { (url, error) in
//            if let ImageUrl = url?.absoluteString{
//                let feedArray: [String: Any] = [
//                    "timestamp": ServerValue.timestamp(),
//                   "from": self.userID,
//                   "image" : ImageUrl ]
//                self.databaseRef.child("Experiences").child(self.experienceKey).child("feed").child(self.imageKeyString+"_feed").setValue(feedArray)
//                
//                self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").observeSingleEvent(of: .value, with: { (snapshot) in
//                    if snapshot.exists(){
//                        
//                        self.databaseRef.child("Experiences").child(self.experienceKey).child("firstImage").setValue(snapshot.value)
//                        
//                        self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
//                        
//                    }else{
//                        self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
//                    }
//                })
//                
//                
//////                Add image to lastImage
////                self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
//                
////                self.databaseRef.child("Experiences").child(self.experienceKey).child("firstImage").setValue(ImageUrl)
//            }
//        }
//    }
//
//        //        Thumbnail
//        let thumbnail = self.storageRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.imageKeyString)
//        let thumbnailImage = self.image.resized(toWidth: 75)
//        let thumbnailImageCompressed = thumbnailImage?.sd_imageData(as: SDImageFormat.webP)
//        let uploadTaskThumbnail = thumbnail.putData(thumbnailImageCompressed!)
//        uploadTaskThumbnail.observe(.success) { snapshot in
//          // Upload completed successfully
//            thumbnail.downloadURL { (url, error) in
//            if let ImageUrl = url?.absoluteString{
//                let thumbnailArray: [String: Any] = [
//                    "timestamp": ServerValue.timestamp(),
//                    "from": self.userID,
//                    "image" : ImageUrl ]
//                self.databaseRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.imageKeyString+"_thumbnail").setValue(thumbnailArray)
//                }
//            }
//        }
//    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.descriptionView.translatesAutoresizingMaskIntoConstraints = true
            self.descriptionView.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
          self.descriptionView.frame.origin.y += keyboardSize.height
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMemoryPreviewToFriendList" {
            let friendListVC = segue.destination as! MemoryFriendListViewController
            friendListVC.experienceKey = self.experienceKey
            friendListVC.descriptionString = self.descriptionTextField.text!
            print(self.descriptionTextField.text!)
            friendListVC.image = self.image
            friendListVC.imageKeyString = self.imageKeyString
        }
    }    
}
