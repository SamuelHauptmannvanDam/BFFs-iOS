//
//  FirstViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 15/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class NotifsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //FIREBASE
    //UserID
    let userID = Auth.auth().currentUser!.uid
    
    //Connect to Firebase
    var ref = Database.database().reference()
    
    var notifFrom = [String]()
    var notifType = [String]()
    var notifExperienceKey = [String]()
    var notifExperienceImageKey = [String]()
    
    @IBOutlet weak var notificationList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        swipeHandler()

        
        notificationList.dataSource = self
        notificationList.delegate = self
        
        fetchNotifResults()

    }
    
        func fetchNotifResults(){
            Database.database().reference().child("Notifications").child(userID).queryOrdered(byChild:"timestamp").observe(.childAdded) { (snapshot) in
              
                let value = snapshot.value as? NSDictionary
                let type = value?["type"] as? String ?? ""
                let from = value?["from"] as? String ?? ""
                let experienceKey = value?["experienceKey"] as? String ?? ""
                let experienceImageKey = value?["image_thumbnail"] as? String ?? ""
                
                
                self.notifType.insert(type, at: 0)
                self.notifFrom.insert(from, at: 0)
                self.notifExperienceKey.insert(experienceKey, at: 0)
                self.notifExperienceImageKey.insert(experienceImageKey, at: 0)
                
                self.notificationList.reloadData()
            }
        }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifFrom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var type = "FriendRequestAndAcceptCell"
        
        if notifType[indexPath.row] == "friend request" {
            type = "FriendRequestAndAcceptCell"            
        } else if notifType[indexPath.row] == "friend request accepted" {
            type = "FriendRequestAndAcceptCell"
        } else if notifType[indexPath.row] == "experience completed" {
            type = "JoinAndInviteCell"
        } else if notifType[indexPath.row] == "experience invite" {
            type = "JoinAndInviteCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath)
        

        //       FRIEND REQUEST
        //
        if notifType[indexPath.row] == "friend request" {
            ref.child("Users").child(notifFrom[indexPath.row]).observe(.value, with: { (snapshot) in
                       
            let value = snapshot.value as? NSDictionary
            let friendListProfileImageLink = value?["image_thumbnail"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
                
            let friendListImage = cell.contentView.viewWithTag(2) as! UIImageView
            friendListImage.sd_setImage(with: URL(string: friendListProfileImageLink))
            
//          Formatting
            let boldAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
            ]
            let regularAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 18.0)!
            ]
            let boldText = NSAttributedString(string: name, attributes: boldAttribute)
            let regularText = NSAttributedString(string: " sent you a friend request!", attributes: regularAttribute)

                let friendRequestDescription = NSMutableAttributedString()
                friendRequestDescription.append(boldText)
                friendRequestDescription.append(regularText)
                
            //Set's names in friendList tableView.
            let friendListName = cell.contentView.viewWithTag(1) as! UILabel
//                friendListName.text = name + " sent you are friend request!"
                friendListName.attributedText = friendRequestDescription
              })
            
        
        //       FRIEND REQUEST ACCEPTED
        //
        } else if notifType[indexPath.row] == "friend request accepted" {
        ref.child("Users").child(notifFrom[indexPath.row]).observe(.value, with: { (snapshot) in
                               
            let value = snapshot.value as? NSDictionary
            let friendListProfileImageLink = value?["image_thumbnail"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
        
            let friendListImage = cell.contentView.viewWithTag(2) as! UIImageView
            friendListImage.sd_setImage(with: URL(string: friendListProfileImageLink))
            
//          Formatting
            let boldAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
            ]
            let regularAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 18.0)!
            ]
            let boldText = NSAttributedString(string: name, attributes: boldAttribute)
            let regularText = NSAttributedString(string: " accepted your friend request!", attributes: regularAttribute)

            let friendAcceptedDescription = NSMutableAttributedString()
                friendAcceptedDescription.append(boldText)
                friendAcceptedDescription.append(regularText)
                
            //Set's names in friendList tableView.
            let friendListName = cell.contentView.viewWithTag(1) as! UILabel
                friendListName.attributedText = friendAcceptedDescription
              })
            
                
                    
        //
        //       EXPERIENCE COMPLETED
        //
        } else if notifType[indexPath.row] == "experience completed" {
            
        let completedExperienceDescription = NSMutableAttributedString()
            
        ref.child("Users").child(notifFrom[indexPath.row]).observe(.value, with: { (snapshot) in
          
            
            
            let value = snapshot.value as? NSDictionary
            let friendListProfileImageLink = value?["image_thumbnail"] as? String ?? ""
            var name = value?["name"] as? String ?? ""
                
            if let nameCut = name.range(of: " ") {
              name.removeSubrange(nameCut.lowerBound..<name.endIndex)
            }
            
            
            let friendImage = cell.contentView.viewWithTag(2) as! UIImageView
            friendImage.sd_setImage(with: URL(string: friendListProfileImageLink))
                
//          Formatting
            let boldAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!]
                
            let regularAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 18.0)!]
            let boldText = NSAttributedString(string: name, attributes: boldAttribute)
            let regularText = NSAttributedString(string: " joined: \n", attributes: regularAttribute)
            
                completedExperienceDescription.append(boldText)
                completedExperienceDescription.append(regularText)
        
          })
            ref.child("Experiences").child(notifExperienceKey[indexPath.row]).child("thumbnails").child(notifExperienceImageKey[indexPath.row]).observe(.value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let image = value?["image"] as? String ?? ""

            let friendImage = cell.contentView.viewWithTag(3) as! UIImageView
            friendImage.sd_setImage(with: URL(string: image))

          })
        
        ref.child("Experiences").child(notifExperienceKey[indexPath.row]).observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let description = value?["description"] as? String ?? ""
            
//          Formatting
            let boldAttribute = [
                         NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
                      ]
           
            let boldTextDescription = NSAttributedString(string: description, attributes: boldAttribute)
            
            completedExperienceDescription.append(boldTextDescription)
            
            //Set's names in friendList tableView.
            let friendListName = cell.contentView.viewWithTag(1) as! UILabel
                friendListName.attributedText = completedExperienceDescription
            
          })

        //
        //       EXPERIENCE INVITE
        //
        } else if notifType[indexPath.row] == "experience invite" {
            
            let inviteExperienceDescription = NSMutableAttributedString()
            
            ref.child("Users").child(notifFrom[indexPath.row]).observe(.value, with: { (snapshot) in
                               
            let value = snapshot.value as? NSDictionary
            let friendListProfileImageLink = value?["image_thumbnail"] as? String ?? ""
            var name = value?["name"] as? String ?? ""

//                Cutter navnet til
                if let nameCut = name.range(of: " ") {
                  name.removeSubrange(nameCut.lowerBound..<name.endIndex)
                }
                
            let friendListImage = cell.contentView.viewWithTag(2) as! UIImageView
            friendListImage.sd_setImage(with: URL(string: friendListProfileImageLink))
            
//          Formatting
            let boldAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
            ]
            let regularAttribute = [
               NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 18.0)!
            ]
            let boldText = NSAttributedString(string: name, attributes: boldAttribute)
            let regularText = NSAttributedString(string: " invited you! \n", attributes: regularAttribute)
          
                inviteExperienceDescription.append(boldText)
                inviteExperienceDescription.append(regularText)
            
//            //Set's names in friendList tableView.
//            let friendListName = cell.contentView.viewWithTag(1) as! UILabel
////                friendListName.text = name + " sent you are friend request!"
//                friendListName.attributedText = newString
                
          })
            
          ref.child("Experiences").child(notifExperienceKey[indexPath.row]).child("thumbnails").child(notifExperienceImageKey[indexPath.row]).observe(.value, with: { (snapshot) in

              let value = snapshot.value as? NSDictionary
              let image = value?["image"] as? String ?? ""

              let friendImage = cell.contentView.viewWithTag(3) as! UIImageView
              friendImage.sd_setImage(with: URL(string: image))

            })
        
        ref.child("Experiences").child(notifExperienceKey[indexPath.row]).observe(.value, with: { (snapshot) in

              let value = snapshot.value as? NSDictionary
              let description = value?["description"] as? String ?? ""

              
  //          Formatting
              let boldAttribute = [
                           NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
                        ]
             
              let boldTextDescription = NSAttributedString(string: description, attributes: boldAttribute)

            
            inviteExperienceDescription.append(boldTextDescription)
              
              //Set's names in friendList tableView.
              let friendListName = cell.contentView.viewWithTag(1) as! UILabel
                  friendListName.attributedText = inviteExperienceDescription
                  
                })
        }
    
          
        
        return cell
    }
    
    
    var notifClicked:String = ""
    var experienceClicked:String = ""
    var notifTypeOnTap = ""
    
      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        Deselct notification
        tableView.deselectRow(at: indexPath, animated: true)
        
        if notifType[indexPath.row] == "experience completed" || notifType[indexPath.row] == "experience invite"  {
            experienceClicked = notifExperienceKey[indexPath.row]
            notifTypeOnTap = notifType[indexPath.row]
            
            self.performSegue(withIdentifier: "fromNotifsToFullHD", sender: nil)
            
        } else {
            notifTypeOnTap = notifType[indexPath.row]
            notifClicked = notifFrom[indexPath.row]
            self.performSegue(withIdentifier: "goToProfileFromNotifs", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if notifTypeOnTap == "experience completed" || notifTypeOnTap == "experience invite"{
            let viewController = segue.destination as! FullHDMemoryViewController
            viewController.experienceKey = experienceClicked
        } else{
            let vc = segue.destination as! profileViewController
            vc.friendUserID = notifClicked
        }
    }
    
    
    func swipeHandler(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }

}

