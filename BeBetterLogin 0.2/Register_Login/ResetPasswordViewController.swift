//
//  ResetPasswordViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 16/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var updateLabel: UILabel!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()
        self.emailTextField.delegate = self;
        
        // Hides Update until needed.
               updateLabel.alpha = 0
        
        //Flair
        Utilities.styleFilledButton(resetPasswordButton)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func resetPasswordTapped(_ sender: Any) {

        
        let email = emailTextField.text!
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
          // ...
        }
        
        updateLabel.alpha = 1
        updateLabel.text = "Email sent, go check it out recruit!"
        
    }
    
    
    
    @IBAction func rememberedPasswordTapped(_ sender: Any) {
        
    self.performSegue(withIdentifier: "goToLogin", sender: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           
            let email = emailTextField.text!
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
              // ...
            }
            
            updateLabel.alpha = 1
            updateLabel.text = "Email sent, go check it out recruit!"

            return true
        }
    
    

}
