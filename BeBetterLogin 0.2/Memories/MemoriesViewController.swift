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

class MemoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //FIREBASE
    //UserID
    let userID = Auth.auth().currentUser!.uid
    
    //Connect to Firebase
    var ref = Database.database().reference()

    var experienceKeys = [String]()
    
    @IBOutlet weak var memoriesList: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeHandler()
        
        memoriesList.dataSource = self
        memoriesList.delegate = self
    
        fetchMemoryList()
        
        

//        On any change to feed.
        ref.child("Feeds").child(userID).queryOrdered(byChild: "timestamp").observe(.childChanged, with: { snapshot in

        self.fetchMemoryList()
        
        }) { (error) in
           print(error.localizedDescription)
            }
        
        
        
    }
    
        func fetchMemoryList(){
    //        First we want to pull a list, of your friends.
            ref.child("Feeds").child(userID).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in
                
            let value = snapshot.value as? NSDictionary
            let experienceKey = value?["experienceKey"] as? String ?? ""
//            self.experienceKeys.append(experienceKey)
            self.experienceKeys.insert(experienceKey, at: 0)
            self.memoriesList.reloadData()
            
            }) { (error) in
               print(error.localizedDescription)
                }
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        experienceKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath)

//        //experienceKeys[indexPath.row] == experienceKey
//        .queryOrdered(byChild: "name")
        ref.child("Experiences").child(experienceKeys[indexPath.row]).observe(.value, with: {     (snapshot) in

            let value = snapshot.value as? NSDictionary
            let lastImage = value?["firstImage"] as? String ?? ""
            let firstImage = value?["lastImage"] as? String ?? ""
            let description = value?["description"] as? String ?? ""

        let firstImageView = cell.contentView.viewWithTag(1) as! UIImageView
        firstImageView.sd_setImage(with: URL(string: firstImage))

        let lastImageView = cell.contentView.viewWithTag(2) as! UIImageView
        lastImageView.sd_setImage(with: URL(string: lastImage))
            
        let descriptionView = cell.contentView.viewWithTag(3) as! UILabel
            descriptionView.text = description
            descriptionView.textDropShadow()

                  }) { (error) in
                    print(error.localizedDescription)
            }
        return cell
    }

    var experienceClicked:String = ""
    
      //Cell Selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        experienceClicked = experienceKeys[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(withIdentifier: "fromMemoriesToFullHD", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! FullHDMemoryViewController
        vc.experienceKey = experienceClicked
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

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }

    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}
