//
//  SecondViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 15/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import CropViewController

class YouViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
// TAG 1 = friendListName
// TAG 2 = friendListImage
// TAGS ARE USED TO CONNECT TO UI IN TABLE CELLS
    
    
    var friendKey = [String]()
    
//    Don't know what it does
//    var friends = [youCellFriend]()
    
    //UI
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var friendList: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    //FIREBASE
    //UserID
    let userID = Auth.auth().currentUser!.uid
    
    //Connect to Firebase
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeHandler()
        
        logoutButton.isHidden = true
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.black.cgColor
        
        setProfile()
       
        friendList.dataSource = self
        friendList.delegate = self
        
        fetchFriendList()
        friendListChanged()
        friendListRemoved()

    }
    
    
    @IBAction func updateNameTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "fromYouToUpdateName", sender: nil)
    }
    
    
    @IBAction func profileImageButtonTapped(_ sender: Any) {
        
        ref.child("Users").child(userID).child("profile").observeSingleEvent(of: .value, with: {
        snapshot in
            if snapshot.exists(){
                self.performSegue(withIdentifier: "fromYouToFullscreen", sender: nil)
            } else {
                self.performSegue(withIdentifier: "fromYouToSelfi", sender: nil)
            }
          }) { (error) in
                         print(error.localizedDescription)
              }
    }
    
    func fetchFriendList(){
        friendKey.removeAll()
        self.friendList.reloadData()
        
//        First we want to pull a list, of your friends.
        ref.child("Friends").child(userID).observeSingleEvent(of: .value, with: {
        snapshot in

            print(snapshot)
            
            for friend in snapshot.children {
                self.friendKey.append((friend as AnyObject).key)
            }
            
            self.friendList.reloadData()
          
            }) { (error) in
                print(error.localizedDescription)
                }
    }
    
//    Detect changes such an unfriending.
    func friendListChanged(){
        ref.child("Friends").child(userID).observe(.childChanged, with: {
        snapshot in
            self.fetchFriendList()
          }) { (error) in
            print(error.localizedDescription)
          }
    }
    
//    If the person only has one friend and that friend unfriend them, the entire child is removed, and actually not detected as a change.
    func friendListRemoved(){
        ref.child("Friends").child(userID).observe(.childRemoved, with: {
        snapshot in
            self.fetchFriendList()
          }) { (error) in
            print(error.localizedDescription)
          }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return friendKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)

        //friendKey[indexPath.row] == userKey
        ref.child("Users").child(friendKey[indexPath.row]).queryOrdered(byChild: "name").observe(.value, with: { (snapshot) in
                   
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
    
    var friendClicked:String = ""
    
      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        friendClicked = friendKey[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "goToProfile", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { 
        if segue.identifier == "goToProfile" {
           let viewController = segue.destination as! profileViewController
            viewController.friendUserID = friendClicked
        }
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.tabBarController!.selectedIndex += 1
        }
        if sender.direction == .right {
            self.tabBarController!.selectedIndex -= 1
        }
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        if logoutButton.isHidden == true
         {
            logoutButton.isHidden = false
        } else if logoutButton.isHidden == false
        {
               logoutButton.isHidden = true
           }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToLogout", sender: nil)
        } catch let logoutError{
            print(logoutError)
        }
    }
        
    func setProfile(){
            ref.child("Users").child(userID).observe(.value, with: { (snapshot) in
               
                let value = snapshot.value as? NSDictionary
                
                let name = value?["name"] as? String ?? ""
//                let user = User(image_thumbnail: username)

                if snapshot.hasChild("image_thumbnail"){
                    let profileImage = value?["image_thumbnail"] as? String ?? ""
                    self.profileImageView.sd_setImage(with: URL(string: profileImage))
                } else{
                    self.profileImageView.image = UIImage(named:"upload")
                }
                
                
                self.profileName.text = name
                
              }) { (error) in
                print(error.localizedDescription)
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
}
