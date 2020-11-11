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



class PreviewViewController: UIViewController, UITextFieldDelegate {
    
    //UserID
    let userID = Auth.auth().currentUser!.uid

    //    Connect to server storage location.
    let storageRef = Storage.storage().reference()
    var databaseRef: DatabaseReference! = Database.database().reference()
    var serverTime = Timestamp.init().seconds
    let BebetterLong: Int64 = 3650000000000000
    var experienceKey: Int64 = 0
    var experienceKeyString = ""
    
//    var thumbnailImageLink = ""
//    var feedImageLink = ""
//    var fullScreenImageLink = ""
    
    var image: UIImage!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var descriptionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        experienceKey = BebetterLong - serverTime
        experienceKeyString = String(experienceKey)
        
        HideKeyboard()
        photo.image = self.image
        
    descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Memory Description", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:1, green:1, blue:1, alpha:0.5)])

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        DispatchQueue.global(qos: .background).async {
////            self.uploadImages()
//        }
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
//        setUpExperience()
        performSegue(withIdentifier: "fromPreviewToFriendlist", sender: nil)
    }
    
    @IBAction func nextFullScreenButton(_ sender: Any) {
//        setUpExperience()
        performSegue(withIdentifier: "fromPreviewToFriendlist", sender: nil)
    }
    
    //    When clicking "return"/ "next" on keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
//        setUpExperience()
        performSegue(withIdentifier: "fromPreviewToFriendlist", sender: nil)
        
        return false
    }
    
    
//    func setUpExperience(){
//        
//        databaseRef.child("Experiences").child(String(experienceKey)).child("timestamp").setValue(ServerValue.timestamp()){
//          (error:Error?, ref:DatabaseReference) in
//          if let error = error {
//            print("Data could not be saved: \(error).")
//          } else {
//            
//            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("participants").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())
//
//            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("invited").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())
//
////            Upload description:
//            let description = self.descriptionTextField.text!
//            
//            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("description").setValue(description)
//            
////            self.uploadImages()
//            self.uploadLinksToExperience()
// 
//                }
//            }
//        }
//    
//    func uploadImages(){
////        FULL SCREEN IMAGES.
////        Location on firebase.
//        let fullHD = self.storageRef.child("Experiences").child(self.experienceKeyString).child("fullHD").child(self.experienceKeyString)
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
//            self.fullScreenImageLink = ImageUrl
//                  }
//              }
//        }
//            
//        //        Feed Image
//        let feed = self.storageRef.child("Experiences").child(self.experienceKeyString).child("feed").child(self.experienceKeyString)
//        let feedImage = self.image.resized(toWidth: 360)
//        let feedCompressed = feedImage?.sd_imageData(as: SDImageFormat.webP)
//        let uploadTaskFeed = feed.putData(feedCompressed!)
//        uploadTaskFeed.observe(.success) { snapshot in
//          // Upload completed successfully
//            feed.downloadURL { (url, error) in
//            if let ImageUrl = url?.absoluteString{
//                self.feedImageLink = ImageUrl
//
//            }
//        }
//    }
//
//        //        Thumbnail
//        let thumbnail = self.storageRef.child("Experiences").child(self.experienceKeyString).child("thumbnails").child(self.experienceKeyString)
//        let thumbnailImage = self.image.resized(toWidth: 75)
//        let thumbnailImageCompressed = thumbnailImage?.sd_imageData(as: SDImageFormat.webP)
//        let uploadTaskThumbnail = thumbnail.putData(thumbnailImageCompressed!)
//        uploadTaskThumbnail.observe(.success) { snapshot in
//          // Upload completed successfully
//            thumbnail.downloadURL { (url, error) in
//            if let ImageUrl = url?.absoluteString{
//                  self.thumbnailImageLink = ImageUrl
//                }
//            }
//        }
//    }
//    
//    func uploadLinksToExperience(){
//        
////        For Thumbnail
//        let thumbnailArray: [String: Any] = [
//            "timestamp": ServerValue.timestamp(),
//            "from": self.userID,
//            "image" : thumbnailImageLink ]
//            self.databaseRef.child("Experiences").child(self.experienceKeyString).child("thumbnails").child(self.experienceKeyString+"_thumbnail").setValue(thumbnailArray)
//        
////        For Feed
//        let feedArray: [String: Any] = [
//            "timestamp": ServerValue.timestamp(),
//            "from": self.userID,
//            "image" : feedImageLink  ]
//            self.databaseRef.child("Experiences").child(self.experienceKeyString).child("feed").child(self.experienceKeyString+"_feed").setValue(feedArray)
//        
////        Sets First image.
//        self.databaseRef.child("Experiences").child(self.experienceKeyString).child("firstImage").setValue(feedImageLink)
//        
//        
////    For FullSCreen
//        let fullHDArray: [String: Any] = [
//          "timestamp": ServerValue.timestamp(),
//            "from": self.userID,
//            "description": self.descriptionTextField.text!,
//            "image" : fullScreenImageLink ]
//        self.databaseRef.child("Experiences").child(self.experienceKeyString).child("fullHD").child(self.experienceKeyString).setValue(fullHDArray)
//        
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
        if segue.identifier == "fromPreviewToFriendlist" {
            let friendListVC = segue.destination as! FriendListViewController
            friendListVC.experienceKey = self.experienceKeyString
            friendListVC.image = self.image
            friendListVC.descriptionString = self.descriptionTextField.text!
        }
    }
 
    
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
