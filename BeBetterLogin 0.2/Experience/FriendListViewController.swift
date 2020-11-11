//
//  FriendListViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 30/05/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var experienceKey = ""
    var image: UIImage!
    var descriptionString = ""
    
    
    //FIREBASE
    //UserID
    let userID = Auth.auth().currentUser!.uid
    var databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var serverTime = Timestamp.init().seconds


    var friendKey = [String]()
    
    @IBOutlet weak var friendList: UITableView!
    @IBOutlet weak var doneButton: UIButton!

//    Used to add selected friends, to this list, which is then used, to invite all friends, when clicking done.
    var invitedList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //flair
        Utilities.styleHollowDullButton(doneButton)
        friendList.dataSource = self
        friendList.delegate = self
        
        fetchFriendList()
       
        setUpExperience()
        
    }
    
    
    func setUpExperience(){
        
        databaseRef.child("Experiences").child(String(experienceKey)).child("timestamp").setValue(ServerValue.timestamp()){
          (error:Error?, ref:DatabaseReference) in
          if let error = error {
            print("Data could not be saved: \(error).")
          } else {
            
            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("participants").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())

            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("invited").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())
            
            self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("description").setValue(self.descriptionString)
 
                }
            }
        }
    
    func uploadImages(){
        
//        FULL SCREEN IMAGES.
//        Location on firebase.
        let fullHD = self.storageRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.experienceKey)
        
//        Resolution of image.
        let fullScreenImage = self.image.resized(toWidth: 720)
        
//        Image turned into data, such that it can be uploaded.
        let fullHDCompressed = fullScreenImage?.sd_imageData(as: SDImageFormat.webP)
        let uploadTaskFullHD = fullHD.putData(fullHDCompressed!)
        uploadTaskFullHD.observe(.success) { snapshot in
          fullHD.downloadURL { (url, error) in
          if let ImageUrl = url?.absoluteString{
           
        //    For FullScreen
        let fullHDArray: [String: Any] = [
          "timestamp": ServerValue.timestamp(),
            "from": self.userID,
            "description": self.descriptionString,
            "image" : ImageUrl ]
        self.databaseRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.experienceKey).setValue(fullHDArray)
                }
            }
        }
            
        //        Feed Image
        let feed = self.storageRef.child("Experiences").child(self.experienceKey).child("feed").child(self.experienceKey)
        let feedImage = self.image.resized(toWidth: 360)
        let feedCompressed = feedImage?.sd_imageData(as: SDImageFormat.webP)
        let uploadTaskFeed = feed.putData(feedCompressed!)
        uploadTaskFeed.observe(.success) { snapshot in
          // Upload completed successfully
            feed.downloadURL { (url, error) in
            if let ImageUrl = url?.absoluteString{
        //        For Feed
            let feedArray: [String: Any] = [
                "timestamp": ServerValue.timestamp(),
                "from": self.userID,
                "image" : ImageUrl  ]
                self.databaseRef.child("Experiences").child(self.experienceKey).child("feed").child(self.experienceKey+"_feed").setValue(feedArray)
            
    //        Sets First image.
            self.databaseRef.child("Experiences").child(self.experienceKey).child("firstImage").setValue(ImageUrl)

            }
        }
    }

        //        Thumbnail
        let thumbnail = self.storageRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.experienceKey)
        let thumbnailImage = self.image.resized(toWidth: 75)
        let thumbnailImageCompressed = thumbnailImage?.sd_imageData(as: SDImageFormat.webP)
        let uploadTaskThumbnail = thumbnail.putData(thumbnailImageCompressed!)
        uploadTaskThumbnail.observe(.success) { snapshot in
          // Upload completed successfully
            thumbnail.downloadURL { (url, error) in
            if let ImageUrl = url?.absoluteString{

            let thumbnailArray: [String: Any] = [
                "timestamp": ServerValue.timestamp(),
                "from": self.userID,
                "image" : ImageUrl ]
                self.databaseRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.experienceKey+"_thumbnail").setValue(thumbnailArray)
                
                }
            }
        }
    }

    func fetchFriendList(){
//        First we want to pull a list, of your friends.
        databaseRef.child("Friends").child(userID).observe(.value, with: {
            snapshot in
            
            for group in snapshot.children {
                self.friendKey.append((group as AnyObject).key)
            }

            self.friendList.reloadData()
          
            }) { (error) in
                           print(error.localizedDescription)
                }
    }
    
//      Adds to invite list.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        invitedList.append(friendKey[indexPath.row])
      
    }
    
//      Removes from invite list.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        invitedList.removeAll { $0 == friendKey[indexPath.row] }
       
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return friendKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

        //friendKey[indexPath.row] == userKey
        databaseRef.child("Users").child(friendKey[indexPath.row]).queryOrdered(byChild: "name").observe(.value, with: { (snapshot) in
                   
                let value = snapshot.value as? NSDictionary
                let friendListProfileImageLink = value?["image_thumbnail"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
            
        let friendListImage = cell.contentView.viewWithTag(2) as! UIImageView
            
        friendListImage.sd_setImage(with: URL(string: friendListProfileImageLink))
            
        //Set's names in friendList tableView.
        let friendListName = cell.contentView.viewWithTag(1) as! UILabel
        friendListName.text = name
            
                  }) { (error) in
                    print(error.localizedDescription)
            }
        return cell
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        sendInvites()
        
        DispatchQueue.global(qos: .background).async {
            self.uploadImages()
        }
         self.performSegue(withIdentifier: "fromFriendListToHome", sender: nil)
    }
    
    
    func sendInvites(){
        for invited in invitedList {
             let notificationData: [String: Any] = [
                "from": self.userID,
                "type": "experience invite",
                "timestamp": ServerValue.timestamp(),
                "experienceKey": experienceKey,
                "image_thumbnail" : experienceKey+"_thumbnail" ]
            
    //            Everyone on invitedList, is invited
            databaseRef.child("Notifications").child(invited).child(experienceKey).setValue(notificationData)
            
    //            Everyone invited, is added to the experience's "invited" section.
            databaseRef.child("Experiences").child(experienceKey).child("invited").child(invited).child("timestamp").setValue(ServerValue.timestamp())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TabBarViewController
        vc.nextViewNumber = 2
    }
    
}
