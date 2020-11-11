//
//  UpdateNameViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 18/06/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class UpdateNameViewController: UIViewController, UITextFieldDelegate {
    
    //Connect to Firebase
    var ref = Database.database().reference()

    //UserID
    let userID = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var updateNameButton: UIButton!
    @IBOutlet weak var guide: UITextView!
//    Where you add your input
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HideKeyboard()
        
        //flair
        Utilities.styleHollowDullButton(updateNameButton)
        ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            self.textField.text = name
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
       self.textField.delegate = self;
        
    }
    
    
    @IBAction func updateNameButtonTapped(_ sender: Any) {
        update()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TabBarViewController
        vc.nextViewNumber = 5
    }
    
    //    When clicking return on keyboard after search.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         update()

        return false
    }
 
    func update(){
        ref.child("Users").child(userID).updateChildValues(["name": textField.text!])
        
//        self.view.makeToast("Name updated", duration: 3.0)
        performSegue(withIdentifier: "fromNameUpdateToYou", sender: nil)
    }
    
}

