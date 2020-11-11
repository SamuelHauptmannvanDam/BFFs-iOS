//
//  FullHDMemoryViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 01/05/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Foundation


////EXPERIENCE OBJECT
class Experience {
    var profileKey: String
    init(profileKey: String) {
        self.profileKey = profileKey
    }
}

class FullHDMemoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FullHDCellDelegate {
    
    var tappedProfileKey = ""
    
//    MY DELEGATE
    func didTapProfile(profileKey: String) {
        
        tappedProfileKey = profileKey
        self.performSegue(withIdentifier: "fromFullHDToProfile", sender: nil)
    }
    
    //Connect to Firebase
    var ref = Database.database().reference()
    var experienceKey = ""
    
    var imageKeys = [String]()
    var imageDescriptions = [String]()
    var froms = [String]()
    var profileImages = [String]()
    var imageLinks = [String]()
    
//    MY LIST OF EXPERIENCES
    var experiencesList: [Experience] = []
    
    @IBOutlet weak var memoryImageList: UICollectionView!
    @IBOutlet weak var memoryTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoryTitle.textDropShadow()

        fetchMemoryList()
        fetchDescription()

        memoryImageList.dataSource = self
//        memoryImageList.delegate = self
        setLayoutFullScreen()
        
    }
    
    func setLayoutFullScreen(){
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        let layout = memoryImageList.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
        
    }
    
    func fetchMemoryList(){
        ref.child("Experiences").child(experienceKey).child("fullHD").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in

        let value = snapshot.value as? NSDictionary
        let imageLink = value?["image"] as? String ?? ""
        let imageDescription = value?["description"] as? String ?? ""
        let from = value?["from"] as? String ?? ""
            
            self.imageLinks.insert(imageLink, at: 0)
            self.imageDescriptions.insert(imageDescription, at: 0)
            self.imageKeys.insert(snapshot.key, at: 0)
            self.froms.insert(from, at: 0)

            self.experiencesList.insert(Experience(profileKey: from), at: 0)
            
            self.memoryImageList.reloadData()

        }) { (error) in
           print(error.localizedDescription)
            }
    }
    
    func fetchDescription(){
        ref.child("Experiences").child(experienceKey).observe(.value, with: { snapshot in

        let value = snapshot.value as? NSDictionary
        let description = value?["description"] as? String ?? ""
        
            print("description")
            print(description)
            self.memoryTitle.text = description

        }) { (error) in
           print(error.localizedDescription)
            }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullHDCell", for: indexPath) as! FullHDCollectionViewCell

        let friendListImage = cell.contentView.viewWithTag(1) as! UIImageView
        friendListImage.sd_setImage(with: URL(string: imageLinks[indexPath.row]))

//        Set Profile Image
        ref.child("Users").child(froms[indexPath.row]).observe(.value, with: { snapshot in

            let value = snapshot.value as? NSDictionary
            let profileImageLink = value?["image_thumbnail"] as? String ?? ""
            
            let profileImage = cell.contentView.viewWithTag(5) as! UIImageView
                profileImage.sd_setImage(with: URL(string: profileImageLink))
//
//            let profileButton = cell.contentView.viewWithTag(5) as! UIImageView
//            profileButton.sd_setImage(string: profileImageLink)
            
        }) { (error) in
               print(error.localizedDescription)
                }

//        Set Description
        let descriptionView = cell.contentView.viewWithTag(2) as! UILabel
            descriptionView.text = imageDescriptions[indexPath.row]
            descriptionView.textDropShadow()
        

        let experienceInCollectionView = experiencesList[indexPath.row]

        cell.setExperience(experience: experienceInCollectionView)
        cell.delegate = self
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromFullHDToProfile" {
            let vc = segue.destination as! profileViewController
            vc.friendUserID = tappedProfileKey
        } else if segue.identifier == "fromFullScreenExperienceToCamera" {
            let previewVC = segue.destination as! MemoryCameraViewController
            previewVC.experienceKey = self.experienceKey
        }
    }
}

////PROTOCALL
protocol FullHDCellDelegate {
     func didTapProfile(profileKey: String)
}

////CELL
class FullHDCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    var experienceItem: Experience!
    var delegate: FullHDCellDelegate?
    
    func setExperience(experience: Experience) {
        experienceItem = experience

    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.didTapProfile(profileKey: experienceItem.profileKey)
    }

}

