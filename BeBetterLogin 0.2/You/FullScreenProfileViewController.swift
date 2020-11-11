//
//  FullScreenProfileViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 11/06/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Foundation

////Image OBJECT
class ImageObject {
    var imageLinkString: String
    var profileKey: String
    init(profileKey: String, imageLinkString: String) {
        self.imageLinkString = imageLinkString
        self.profileKey = profileKey
    }
}

class FullScreenProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FullscreenCellDelegate{
    
    var tappedProfileKey = ""
    var tappedLinkString = ""
    

    //    MY DELEGATE
        func didTapProfile(profileKey: String, imageLinkString: String) {
            tappedProfileKey = profileKey
            delete()
        }
    
    //UserID
    let userID = Auth.auth().currentUser!.uid
    
    //Connect to Firebase
    var ref = Database.database().reference()

    @IBOutlet weak var profileImageList: UICollectionView!
    
    var imageLinks = [String]()
    
    //    MY LIST OF EXPERIENCES
    var imageObjectLink: [ImageObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutFullScreen()
        fetchProfileImageList()
        
        profileImageList.dataSource = self
//        profileImageList.delegate = self
    }
    
    func delete(){
         
//        Delete profile imagelink & file
        ref.child("Users").child(userID).child("profile").child(tappedProfileKey).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let profileLink = value?["profile"] as? String ?? ""
            
//              Delete link
            self.ref.child("Users").child(self.userID).child("profile").child(self.tappedProfileKey).removeValue()

//              Delete file
            Storage.storage().reference(forURL: profileLink).delete { error in
                if let error = error {
                // Uh-oh, an error occurred!
                } else {
                // File deleted successfully
                    self.fetchProfileImageList()
                }
            }
                
//            Deltes profile image if it is the last added.
            self.ref.child("Users").child(self.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let imageLink = value?["image"] as? String ?? ""
                
//                CHECK IF IMAGE IS PROFILE IMAGE
                if imageLink == profileLink {
                    self.ref.child("Users").child(self.userID).child("image").removeValue()
                    self.ref.child("Users").child(self.userID).child("image_thumbnail").removeValue()
                }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        
        
        self.ref.child("Users").child(self.userID).child("profile_thumbnail").child(self.tappedProfileKey+"_thumbnail").observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
          let profilethumbnailLink = value?["profile_thumbnail"] as? String ?? ""
//            Delete link
            self.ref.child("Users").child(self.userID).child("profile_thumbnail").child(self.tappedProfileKey+"_thumbnail").removeValue()
//            Delete file
            Storage.storage().reference(forURL: profilethumbnailLink).delete { error in
                if let error = error {
                // Uh-oh, an error occurred!
                } else {
                // File deleted successfully

                }
            }
            }) { (error) in
                print(error.localizedDescription)
            }
        

        }
    
   func setLayoutFullScreen(){
            let height = UIScreen.main.bounds.height
            let width = UIScreen.main.bounds.width
            let layout = profileImageList.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: height)
        }
        
    func fetchProfileImageList(){
        
        imageLinks.removeAll()
        imageObjectLink.removeAll()
        
        ref.child("Users").child(userID).child("profile").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in

        let value = snapshot.value as? NSDictionary
        let imageLink = value?["profile"] as? String ?? ""
            
            self.imageLinks.insert(imageLink, at: 0)
                        
//            FIND PATH OR SOMETHING TO IMAGE
            self.imageObjectLink.insert(ImageObject(profileKey: snapshot.key,imageLinkString: imageLink), at: 0)
        
            self.profileImageList.reloadData()

        }) { (error) in
           print(error.localizedDescription)
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLinks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullscreenCell", for: indexPath) as! FullscreenCollectionViewCell
    
        let profimeImageListImage = cell.contentView.viewWithTag(1) as! UIImageView
        let deleteButton = cell.contentView.viewWithTag(2) as! UIButton

        profimeImageListImage.sd_setImage(with: URL(string: imageLinks[indexPath.row]))
        
        let imageInCollectionView = imageObjectLink[indexPath.row]
        cell.setImageLink(image: imageInCollectionView)
        cell.delegate = self
        
        return cell
        }
    
    @IBAction func toProfileCameraButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "fromFullScreenProfileToSelfi", sender: nil)
    }
}

////PROTOCALL
protocol FullscreenCellDelegate {
     func didTapProfile(profileKey: String, imageLinkString: String)
}

////CELL
class FullscreenCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    
    var imageClass: ImageObject!
    var delegate: FullscreenCellDelegate?
    
    func setImageLink(image: ImageObject) {
        imageClass = image
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.didTapProfile(profileKey: imageClass.profileKey, imageLinkString: imageClass.imageLinkString)
    }
}


