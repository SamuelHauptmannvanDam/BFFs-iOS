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

class MemoryFriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {


    var experienceKey = "" //    The original BeBetterLong - Minus servertime.
    var descriptionString = ""
    var imageKeyString = "" //    The unique for this specific image :: BeBetterLong - Minus servertime.
    var image: UIImage!
    
    
    //FIREBASE
    //UserID
    let userID = Auth.auth().currentUser!.uid
    var databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var serverTime = Timestamp.init().seconds

//    For our tableview
    var friendList = [String]()
    
    @IBOutlet weak var friendListTable: UITableView!
    @IBOutlet weak var doneButton: UIButton!

    //    Used to add selected friends, to this list, which is then used, to invite all friends, when clicking done.
    
    var invitedList = [String]()
    var participantList = [String]()
    var participatingFriendList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //flair
        Utilities.styleHollowDullButton(doneButton)
        friendListTable.dataSource = self
        friendListTable.delegate = self
        
        fetchFriendList()
        setUpExperience()
  
    }
    
    
    //        First we want to pull a list, of your friends.
    func fetchFriendList(){
        databaseRef.child("Friends").child(userID).observe(.value, with: {
            snapshot in
            for group in snapshot.children {
                self.friendList.append((group as AnyObject).key)
            }
            self.friendListTable.reloadData()
            self.fetchParticipantList()
            }) { (error) in
                print(error.localizedDescription)
            }
    }
    
    func fetchParticipantList(){
        databaseRef.child("Experiences").child(experienceKey).child("participants").observeSingleEvent(of: .value, with: {
            snapshot in
            for group in snapshot.children {
                self.participantList.append((group as AnyObject).key)
            }
            self.fetchParticipatingFriendList()
            }) { (error) in
                    print(error.localizedDescription)
                }
            }
    
//    We Check if our friends are participating already - we want to give them a notification about our participation.
    func fetchParticipatingFriendList(){
        for name in participantList {
            if friendList.contains(name) {
                participatingFriendList.append(name)
            }
        }
    }
    
    
//      Adds to invite list.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        invitedList.append(friendList[indexPath.row])
    }
    
//      Removes from invite list.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        invitedList.removeAll { $0 == friendList[indexPath.row] }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

        //friendKey[indexPath.row] == userKey
        databaseRef.child("Users").child(friendList[indexPath.row]).queryOrdered(byChild: "name").observe(.value, with: { (snapshot) in
                   
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
        
        self.performSegue(withIdentifier: "fromMemoryFriendListToHome", sender: nil)
     
    }
    
    func sendInvites(){
        //        Inviting new additional users.
                    for invited in invitedList {
                        let notificationData: [String: Any] = [
                        "from": self.userID,
                        "type": "experience invite",
                        "timestamp": ServerValue.timestamp(),
                        "experienceKey": experienceKey,
                        "image_thumbnail" : experienceKey+"_thumbnail" ]

        //            WE SHOULD CHECK IF THEY ARE ALREADY PARTICIPATING
        //            Everyone on invitedList, is invited
                    databaseRef.child("Notifications").child(invited).child(experienceKey).setValue(notificationData)

        //            Everyone invited, is added to the experience's "invited" section.
                    databaseRef.child("Experiences").child(experienceKey).child("invited").child(invited).child("timestamp").setValue(ServerValue.timestamp())
                }

        //        Now we want to add the memory, to the top of everyone who has participated's feed. This also sets the experience on top in everyones feed.
                let experienceLink: [String: Any] = [
                     "type": "together",
                     "timestamp": ServerValue.timestamp(),
                     "experienceKey": experienceKey,]
        //        Add experience to everyone participatings memories/ set it to the top of memories.
                for participants in participantList{
                    databaseRef.child("Feeds").child(participants).child(experienceKey).setValue(experienceLink)
           }
        //        Add it to your own feed.
                databaseRef.child("Feeds").child(userID).child(experienceKey).setValue(experienceLink)

        //       Now we want to let all our friends who is participating know, that we've joined.
                for participatingFriends in participatingFriendList {
                 let notificationData: [String: Any] = [
                    "from": self.userID,
                    "type": "experience completed",
                    "timestamp": ServerValue.timestamp(),
                    "experienceKey": experienceKey,
                    "image_thumbnail" : experienceKey+"_thumbnail" ]
                databaseRef.child("Notifications").child(participatingFriends).child(experienceKey).setValue(notificationData)
                }
    }

        func setUpExperience(){
            
    //        Updates timestamp for experience, which is nice so it comes up top in your memories.
            databaseRef.child("Experiences").child(String(experienceKey)).child("timestamp").setValue(ServerValue.timestamp()){
              (error:Error?, ref:DatabaseReference) in
              if let error = error {
                print("Data could not be saved: \(error).")
              } else {
                
    //            Adds yourself to participation.
                self.databaseRef.child("Experiences").child(String(self.experienceKey)).child("participants").child(self.userID).child("timestamp").setValue(ServerValue.timestamp())
     
                    }
                }
            }
        
        func uploadImages(){
    //        FULL SCREEN IMAGES.
    //        Location on firebase.
            
    //        IF I change imageKeyString to experienceKey, I will override the image which has worked in the past to keep server use low.
            let fullHD = self.storageRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.imageKeyString)
            
    //        Resolution of image.
            let fullScreenImage = self.image.resized(toWidth: 720)
            
    //        Image turned into data, such that it can be uploaded.
            let fullHDCompressed = fullScreenImage?.sd_imageData(as: SDImageFormat.webP)
            let uploadTaskFullHD = fullHD.putData(fullHDCompressed!)
            uploadTaskFullHD.observe(.success) { snapshot in
              fullHD.downloadURL { (url, error) in
              if let ImageUrl = url?.absoluteString{
                  let fullHDArray: [String: Any] = [
                    "timestamp": ServerValue.timestamp(),
                      "from": self.userID,
                      "description": self.descriptionString,
                      "image" : ImageUrl ]
                  self.databaseRef.child("Experiences").child(self.experienceKey).child("fullHD").child(self.imageKeyString).setValue(fullHDArray)
                      }
                  }
            }
                
            //        Feed Image
            let feed = self.storageRef.child("Experiences").child(self.experienceKey).child("feed").child(self.imageKeyString)
            let feedImage = self.image.resized(toWidth: 360)
            let feedCompressed = feedImage?.sd_imageData(as: SDImageFormat.webP)
            let uploadTaskFeed = feed.putData(feedCompressed!)
            uploadTaskFeed.observe(.success) { snapshot in
               // Upload completed successfully
                feed.downloadURL { (url, error) in
                if let ImageUrl = url?.absoluteString{
                    let feedArray: [String: Any] = [
                        "timestamp": ServerValue.timestamp(),
                       "from": self.userID,
                       "image" : ImageUrl ]
                    self.databaseRef.child("Experiences").child(self.experienceKey).child("feed").child(self.imageKeyString+"_feed").setValue(feedArray)
                    
                    self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            
                            self.databaseRef.child("Experiences").child(self.experienceKey).child("firstImage").setValue(snapshot.value)
                            
                            self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
                            
                        }else{
                            self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
                        }
                    })
                    
                    
    ////                Add image to lastImage
    //                self.databaseRef.child("Experiences").child(self.experienceKey).child("lastImage").setValue(ImageUrl)
                    
    //                self.databaseRef.child("Experiences").child(self.experienceKey).child("firstImage").setValue(ImageUrl)
                }
            }
        }

            //        Thumbnail
            let thumbnail = self.storageRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.imageKeyString)
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
                    self.databaseRef.child("Experiences").child(self.experienceKey).child("thumbnails").child(self.imageKeyString+"_thumbnail").setValue(thumbnailArray)
                    }
                }
            }
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
