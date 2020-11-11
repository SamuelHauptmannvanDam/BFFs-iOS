//
//  SecondViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 15/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // TAG 1 = friendListName
    // TAG 2 = friendListImage
    // TAGS ARE USED TO CONNECT TO UI IN TABLE CELLS

    var userName = [String]()
    var userImage = [String]()
    var userKey = [String]()
    
    @IBOutlet weak var SearchField: UITextField!
    @IBOutlet weak var SearchResult: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeHandler()
        
        Utilities.styleHollowTextfield(SearchField)
        
        fetchSearchResults()
        
        SearchField.delegate = self
        SearchResult.dataSource = self
        SearchResult.delegate = self
        
//        Starts searching when intering a letter
        SearchField.addTarget(self,
        action : #selector(textFieldDidChange),
        for : .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.SearchField.translatesAutoresizingMaskIntoConstraints = true
            self.SearchField.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
          self.SearchField.frame.origin.y += keyboardSize.height
        }
    }
    
//  Searches for person, as soon as the user gives any input.
    @objc func textFieldDidChange(){
        fetchSearchResults()
    }
    
//    When clicking return on keyboard after search.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fetchSearchResults()
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func searchDone(_ sender: Any) {
    }
    
    func fetchSearchResults(){
   
        self.userName.removeAll()
        self.userImage.removeAll()
        self.userKey.removeAll()
        
        self.SearchResult.reloadData()
        
        Database.database().reference().child("Users").queryOrdered(byChild: "name").queryStarting(atValue: SearchField.text!).queryEnding(atValue: SearchField.text!+"\u{f8ff}").observe(.childAdded) { (snapshot) in
          
            let value = snapshot.value as? NSDictionary
            let profileImage = value?["image_thumbnail"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            
            self.userName.append(name)
            self.userImage.append(profileImage)
            self.userKey.append(snapshot.key)
            
            self.SearchResult.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)

 
        
        let friendListImage = cell.contentView.viewWithTag(2) as! UIImageView
        friendListImage.sd_setImage(with: URL(string: userImage[indexPath.row]))
        


        //Set's names in friendList tableView.
        let friendListName = cell.contentView.viewWithTag(1) as! UILabel
        friendListName.text = userName[indexPath.row]
        
        return cell
    }
    
    
    var friendClicked:String = ""
    
      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
//        Closes keyboard and resets location of SearchField.
        self.view.endEditing(true)
        print(userKey[indexPath.row])
        
        friendClicked = userKey[indexPath.row]
        self.performSegue(withIdentifier: "goToProfileFromSearch", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! profileViewController
        vc.friendUserID = friendClicked
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
    
    @objc func keyboardWillChange(notification: Notification) {
//        print("Keyboard will show: \(notification.name.rawValue)")
    }
}
