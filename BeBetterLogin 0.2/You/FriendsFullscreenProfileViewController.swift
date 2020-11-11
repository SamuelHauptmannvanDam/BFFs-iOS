//
//  FullScreenProfileViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 11/06/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase

class FriendsFullscreenProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    //FriendUserID
    var friendUserID = ""
    
    //Connect to Firebase
    var ref = Database.database().reference()
    
    @IBOutlet weak var profileImageList: UICollectionView!
    
    var imageLinks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutFullScreen()
        fetchProfileImageList()
        
        profileImageList.dataSource = self
        profileImageList.delegate = self
        
    }
    
   func setLayoutFullScreen(){
            let height = UIScreen.main.bounds.height
            let width = UIScreen.main.bounds.width
            let layout = profileImageList.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: height)
            
        }
        
    func fetchProfileImageList(){
        ref.child("Users").child(friendUserID).child("profile").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in

            print(snapshot)
        let value = snapshot.value as? NSDictionary
        let imageLink = value?["profile"] as? String ?? ""
            
            self.imageLinks.insert(imageLink, at: 0)
            print(imageLink)

                self.profileImageList.reloadData()

        }) { (error) in
           print(error.localizedDescription)
            }
        print(imageLinks)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLinks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullHDCell", for: indexPath) as! FullHDCollectionViewCell

            let profimeImageListImage = cell.contentView.viewWithTag(1) as! UIImageView
            profimeImageListImage.sd_setImage(with: URL(string: imageLinks[indexPath.row]))

            return cell
        }
    
}
