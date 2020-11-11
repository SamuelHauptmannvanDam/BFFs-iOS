//
//  profileViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 19/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase

class profile2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

// TAG 1 = friendListName
// TAG 2 = friendListImage
// TAGS ARE USED TO CONNECT TO UI IN TABLE CELLS
    
    let userID2 = Auth.auth().currentUser!.uid
    var friendUserID2 = ""
    var friendKey2 = [String]()
    var friends2 = [youCellFriend]()
    
    var friendState2 = "not_friends"

    @IBOutlet weak var friendList: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var FriendRequestButton: UIButton!
    
    //Connect to Firebase
    var ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setProfile()
        
        friendList.dataSource = self
        friendList.delegate = self
         
        fetchFriendList()
        
        checkFriendshipStatus()
        hideButtonIfYourself()
        
        //flair
        Utilities.styleFilledButton(FriendRequestButton)
        
        
    }
    
    func hideButtonIfYourself(){
        if friendUserID2 == userID2{
            FriendRequestButton.isHidden = true
        }

    }
    
    
    func checkFriendshipStatus(){
        ref.child("Friends").child(userID2).child(friendUserID2).observe(DataEventType.value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let friendType = value?["friend_type"] as? String ?? ""

            if !friendType.isEmpty{
                self.friendState2 = friendType
            }
            
            if friendType == "friends"{

                Utilities.styleHollowButton(self.FriendRequestButton)
                self.FriendRequestButton.setTitle("Unfriend",for: .normal)
                self.FriendRequestButton.backgroundColor = .white

            }

            if friendType == "not_friends"{

                Utilities.styleFilledButton(self.FriendRequestButton)
                self.FriendRequestButton.setTitle("Send Friend Request",for: .normal)
                self.friendState2 = "not_friends"

            }

            }) { (error) in
              print(error.localizedDescription)
          }
        
        
        ref.child("Friend_req").child(userID2).child(friendUserID2).observe(.value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let friendType = value?["request_type"] as? String ?? ""
            
            if !friendType.isEmpty{
                self.friendState2 = friendType
            }
            
            if friendType == "req_received"{
                
                Utilities.styleFilledButton(self.FriendRequestButton)
                self.FriendRequestButton.setTitle("Accept Friend Request",for: .normal)
                
            }
            
            if friendType == "req_sent"{
                
                self.FriendRequestButton.setTitle("Cancel Friend Request",for: .normal)
                self.FriendRequestButton.backgroundColor = .white
                Utilities.styleHollowDullButton(self.FriendRequestButton)
                
            }
            
            if friendType == "not_friends"{
                
                Utilities.styleFilledButton(self.FriendRequestButton)
                self.FriendRequestButton.setTitle("Send Friend Request",for: .normal)
                
            }
        
            }) { (error) in
              print(error.localizedDescription)
          }
    }
    
    
    
    @IBAction func FriendRequestTabbed(_ sender: Any) {
                
        //      NOT FRIENDS STATE
                if friendState2 == "not_friends"{
                    ref.child("Friend_req").child(userID2).child(friendUserID2).child("request_type").setValue("req_sent")
                    ref.child("Friend_req").child(friendUserID2).child(userID2).child("request_type").setValue("req_received")
                    friendState2 = "req_sent"

        //      ADD NOTIFICATION -> REQUESTING FRIENDSHIP
                    let RequestFriendship = [
                                "from": userID2,
                                "type": "friend request",
                                "timestamp": ServerValue.timestamp()] as [String : Any]
                    ref.child("Notifications").child(friendUserID2).childByAutoId().setValue(RequestFriendship)
                }
                
                
        //        CANCEL FRIEND REQUEST
                else if friendState2 == "req_sent"{
                    ref.child("Friend_req").child(userID2).child(friendUserID2).child("request_type").setValue("not_friends")
                    ref.child("Friend_req").child(friendUserID2).child(userID2).child("request_type").setValue("not_friends")
                    
                }
                
        //        REQ RECEIVED -> ACCEPTING FRIEND REQUEST
                else if friendState2 == "req_received" {
                    let friendMap = ["participationCount": 0,
                                     "friend_type": "friends",
                                     "timestamp": ServerValue.timestamp()] as [String : Any]
                
                ref.child("Friends").child(userID2).child(friendUserID2).setValue(friendMap)
                ref.child("Friends").child(friendUserID2).child(userID2).setValue(friendMap)
                   
        //      Deletes friend req listing.
                ref.child("Friend_req").child(userID2).child(friendUserID2).removeValue()
                ref.child("Friend_req").child(friendUserID2).child(userID2).removeValue()
                    
        //      ADD NOTIFICATIONS -> FRIEND REQUEST ACCEPTED
                    let NotificationFriendshipAccepted =
                        ["from": userID2,
                         "type": "friend request accepted",
                         "timestamp": ServerValue.timestamp()] as [String : Any]
                    
                    ref.child("Notifications").child(friendUserID2).childByAutoId().setValue(NotificationFriendshipAccepted)
                    
                }
        //        UNFRIENDING
                else if friendState2 == "friends"{
                    ref.child("Friends").child(userID2).child(friendUserID2).child("friend_type").setValue("not_friends")
                    ref.child("Friends").child(friendUserID2).child(userID2).child("friend_type").setValue("not_friends")
                    
                    friendState2 = "not_friends"

                    ref.child("Friends").child(userID2).child(friendUserID2).removeValue()
                    ref.child("Friends").child(friendUserID2).child(userID2).removeValue()
                }
        
    }
    
        

    var friendClicked:String = ""

      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        friendClicked = friendKey2[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "goToProfile3", sender: profileViewController.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile3" {
             let vc = segue.destination as! profileViewController
                   vc.friendUserID = friendClicked
        }
        
        if segue.identifier == "fromProfileToFullScreen" {
             let vc = segue.destination as! FriendsFullscreenProfileViewController
                   vc.friendUserID = friendUserID2
        }
       
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return friendKey2.count
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

          //friendKey[indexPath.row] == userKey
        ref.child("Users").child(friendKey2[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                     
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
        
        ref.child("Friends").child(friendUserID2).observe(.value, with: {
            snapshot in
            
            for group in snapshot.children {
                self.friendKey2.append((group as AnyObject).key)
            }

            self.friendList.reloadData()

          
            }) { (error) in
                           print(error.localizedDescription)
                }
    }
        
    
    func setProfile(){
        
        ref.child("Users").child(friendUserID2).observeSingleEvent(of: .value, with: { (snapshot) in
               
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
