//
//  RegisterViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 15/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController{
    func HideKeyboard() {
         let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
               view.addGestureRecognizer(Tap)
        }
     @objc func DismissKeyboard(){
         view.endEditing(true)
    }
}

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var claimButton: UIButton!
    
    @IBOutlet weak var termsOfService: UITextView!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()
        self.fullName.delegate = self;
        self.email.delegate = self;
        self.password.delegate = self;
        
        updatetermsOfService()
        
        // Hides Error until needed.
        errorLabel.alpha = 0
        
        //Add button flair.
        Utilities.styleFilledButton(claimButton)
    }
    
    func updatetermsOfService(){
        
        
        let attributedString = NSMutableAttributedString(string: "By tapping claim, you achknowledge that you have read the Privacy Policy and agree to the Terms of Service.")
        
        let urlPrivacyPolicy = URL(string: "https://sites.google.com/view/bebetterorganisation/privacy-policy")!
        let urlTermsOfService = URL(string: "https://sites.google.com/view/bebetterorganisation/terms-of-service")!

        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: urlPrivacyPolicy], range: NSMakeRange(58, 14))
        attributedString.setAttributes([.link: urlTermsOfService], range: NSMakeRange(90, 16))
        
        self.termsOfService.attributedText = attributedString
        self.termsOfService.isUserInteractionEnabled = true
        self.termsOfService.isEditable = false

        // Set how links should appear: blue and underlined
        self.termsOfService.linkTextAttributes = [
            .foregroundColor: UIColor(red: 0.00, green: 0.52, blue: 0.47, alpha: 1.00),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
     func validateFields() -> String? {
            
            // Check that all fields are filled in.
            if fullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            {
                return "Please fill in all fields."
            }
            
            if password.text!.count < 6
            {
                return "Password has to be 6 characters or more"
            }
            
            return nil
        }
    
    @IBAction func alreadyHaveAnAccountTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "goLogin", sender: nil)
    }

    @IBAction func claimTapped(_ sender: Any) {
                    claim()
                }

    func showError(_ message:String){
          errorLabel.text = message
          errorLabel.alpha = 1
      }
      
      private var authUser : User? {
          return Auth.auth().currentUser
      }

      public func sendVerificationMail() {
          if self.authUser != nil && !self.authUser!.isEmailVerified {
              self.authUser!.sendEmailVerification(completion: { (error) in
                  // Notify the user that the mail has sent or couldn't because of an error.
              })
          }
          else {
              // Either the user is not available, or the user is already verified.
          }
      }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if password.isFirstResponder == true {
         view.endEditing(true)
         claim()
        } else if fullName.isFirstResponder == true {
            self.email.becomeFirstResponder()
        
        } else if email.isFirstResponder == true {
            self.password.becomeFirstResponder()
        }
        
        return false
     }
    
    func claim(){
        // Validate the fields
        let error = validateFields()
        if error != nil {
            // There's something wrong with the fields, show error message.
            showError(error!)
        } else {
            
            // cleaned versions of the data
            let fullNametext = fullName.text!
            let emailText = email.text!
            let passwordText = password.text!
            
            // Create the user
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { (result, error) in
             
                // Check for Errors
                if error != nil{
                    // There was an error creating the user
                    self.showError("Error creating user")
                    } else {
                 
                 if (Auth.auth().currentUser?.uid) != nil{
                     
                     let user = Auth.auth().currentUser?.uid
                     self.ref = Database.database().reference()
                     self.ref.child("Users").child(user!).setValue(["name": fullNametext])
                     self.sendVerificationMail()
                                 
                     // Transition to the home screen
                     self.performSegue(withIdentifier: "goHomeFromRegister", sender: nil)
                     
                             }
                         }
                     }
                 }
    }
    
    
    }
    
