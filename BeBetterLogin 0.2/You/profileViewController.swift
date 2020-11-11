//
//  profileViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 19/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase

class profileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

// TAG 1 = friendListName
// TAG 2 = friendListImage
// TAGS ARE USED TO CONNECT TO UI IN TABLE CELLS
    
    //UserID = encrypted name of the person.
    let userID = Auth.auth().currentUser!.uid
    var friendUserID = ""
    var friendKey = [String]()
//    var friends = [youCellFriend]()
    
    var friendState = "not_friends"
    

    @IBOutlet weak var friendList: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sendFriendRequest: UIButton!
    
    //Connect to Firebase
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setProfile()
        
        friendList.dataSource = self
        friendList.delegate = self
         
        fetchFriendList()
        
        //flair
        Utilities.styleFilledButton(sendFriendRequest)
        
        checkFriendshipStatus()
        hideButtonIfYourself()
        
    }
    
    func hideButtonIfYourself(){
        if friendUserID == userID{
            sendFriendRequest.isHidden = true
        }

    }
        
    func checkFriendshipStatus(){
        ref.child("Friends").child(userID).child(friendUserID).observe(DataEventType.value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let friendType = value?["friend_type"] as? String ?? ""

            if !friendType.isEmpty{
                self.friendState = friendType
            }
            
            if friendType == "friends"{

                Utilities.styleHollowButton(self.sendFriendRequest)
                self.sendFriendRequest.setTitle("Unfriend",for: .normal)
                self.sendFriendRequest.backgroundColor = .white

            }

            if friendType == "not_friends"{

                Utilities.styleFilledButton(self.sendFriendRequest)
                self.sendFriendRequest.setTitle("Send Friend Request",for: .normal)
                self.friendState = "not_friends"

            }

            }) { (error) in
              print(error.localizedDescription)
          }
        
        
        ref.child("Friend_req").child(userID).child(friendUserID).observe(.value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let friendType = value?["request_type"] as? String ?? ""
            
            if !friendType.isEmpty{
                self.friendState = friendType
            }
            
            if friendType == "req_received"{
                
                Utilities.styleFilledButton(self.sendFriendRequest)
                self.sendFriendRequest.setTitle("Accept Friend Request",for: .normal)
                
            }
            
            if friendType == "req_sent"{
                
                self.sendFriendRequest.setTitle("Cancel Friend Request",for: .normal)
                self.sendFriendRequest.backgroundColor = .white
                Utilities.styleHollowDullButton(self.sendFriendRequest)
                
            }
            
            if friendType == "not_friends"{
                
                Utilities.styleFilledButton(self.sendFriendRequest)
                self.sendFriendRequest.setTitle("Send Friend Request",for: .normal)
                
            }
        
            }) { (error) in
              print(error.localizedDescription)
          }
    }
    
    
    
    @IBAction func friendRequestTapped(_ sender: Any) {
        
//      NOT FRIENDS STATE
        if friendState == "not_friends"{
            ref.child("Friend_req").child(userID).child(friendUserID).child("request_type").setValue("req_sent")
            ref.child("Friend_req").child(friendUserID).child(userID).child("request_type").setValue("req_received")
            friendState = "req_sent"

//      ADD NOTIFICATION -> REQUESTING FRIENDSHIP
            let RequestFriendship = [
                        "from": userID,
                        "type": "friend request",
                        "timestamp": ServerValue.timestamp()] as [String : Any]
            ref.child("Notifications").child(friendUserID).childByAutoId().setValue(RequestFriendship)
        }
        
        
//        CANCEL FRIEND REQUEST
        else if friendState == "req_sent"{
            ref.child("Friend_req").child(userID).child(friendUserID).child("request_type").setValue("not_friends")
            ref.child("Friend_req").child(friendUserID).child(userID).child("request_type").setValue("not_friends")
            
        }
        
//        REQ RECEIVED -> ACCEPTING FRIEND REQUEST
        else if friendState == "req_received" {
            let friendMap = ["participationCount": 0,
                             "friend_type": "friends",
                             "timestamp": ServerValue.timestamp()] as [String : Any]
        
        ref.child("Friends").child(userID).child(friendUserID).setValue(friendMap)
        ref.child("Friends").child(friendUserID).child(userID).setValue(friendMap)
           
//      Deletes friend req listing.
        ref.child("Friend_req").child(userID).child(friendUserID).removeValue()
        ref.child("Friend_req").child(friendUserID).child(userID).removeValue()
            
//      ADD NOTIFICATIONS -> FRIEND REQUEST ACCEPTED
            let NotificationFriendshipAccepted =
                ["from": userID,
                 "type": "friend request accepted",
                 "timestamp": ServerValue.timestamp()] as [String : Any]
            
            ref.child("Notifications").child(friendUserID).childByAutoId().setValue(NotificationFriendshipAccepted)
            
        }
//        UNFRIENDING
        else if friendState == "friends"{
            ref.child("Friends").child(userID).child(friendUserID).child("friend_type").setValue("not_friends")
            ref.child("Friends").child(friendUserID).child(userID).child("friend_type").setValue("not_friends")
            
            friendState = "not_friends"

            ref.child("Friends").child(userID).child(friendUserID).removeValue()
            ref.child("Friends").child(friendUserID).child(userID).removeValue()
        }
        
        
    }
    
    
    
    
    var friendClicked:String = ""

      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        friendClicked = friendKey[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "goToProfile2", sender: profileViewController.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile2" {
            let vc = segue.destination as! profile2ViewController
            vc.friendUserID2 = friendClicked
        }
        
        if segue.identifier == "fromProfileToFullScreen" {
             let vc = segue.destination as! FriendsFullscreenProfileViewController
                   vc.friendUserID = friendUserID
        }
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return friendKey.count
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

          //friendKey[indexPath.row] == userKey
        ref.child("Users").child(friendKey[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                     
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
      

        
        
        
    func fetchFriendList(){
//        First we want to pull a list, of your friends.
        
        ref.child("Friends").child(friendUserID).observe(DataEventType.value, with: {
            snapshot in
            
            for group in snapshot.children {
                self.friendKey.append((group as AnyObject).key)
            }

            self.friendList.reloadData()

          
            }) { (error) in
                           print(error.localizedDescription)
                }
    }
        
    
    func setProfile(){
        
        ref.child("Users").child(friendUserID).observeSingleEvent(of: .value, with: { (snapshot) in
               
            let value = snapshot.value as? NSDictionary
            let profileImage = value?["image_thumbnail"] as? String ?? ""
//            let name = value?["name"] as? String ?? ""

            self.profileImageView.sd_setImage(with: URL(string: profileImage))
//            self.profileName.text = name
            
              }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    
    
    
    
}
