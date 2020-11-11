//
//  LoginViewController.swift
//  tabbedApp
//
//  Created by Samuel Hauptmann van Dam on 14/04/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        //Hides errorLabel until needed.
        errorLabel.alpha = 0
        self.emailTextField.delegate = self;
        self.passwordTextField.delegate = self;

        //flair
        Utilities.styleFilledButton(loginButton)

    }
    
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if passwordTextField.isFirstResponder == true {
            login()
            } else {
            passwordTextField.becomeFirstResponder()
            }
          // Do not add a line break
          return false
       }
    
    @IBAction func forgotYourPasswordTapped(_ sender: Any) {
          self.performSegue(withIdentifier: "goForgottenPassword", sender: nil)
    }
    
    @IBAction func newAccountTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "goRegister", sender: nil)
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        login()
    }
    
    func validateFields() -> String? {
        // Check that all fields are filled in.
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        return nil
    }
    
        func showError(_ message:String){
            errorLabel.text = message
            errorLabel.alpha = 1
           }
    
    func login(){
        // Validate Text Fields
        let error = validateFields()
        if error != nil {
            // There's something wrong with the fields, show error message.
            showError(error!)
        }
        else {
            let email = emailTextField.text!
            let password = passwordTextField.text!
                   // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                 if error != nil{
                     //Couln't sign in.
                     self.showError("Email or password, doesn't match an account.")
                 } else {
                 //GET IN
                    self.performSegue(withIdentifier: "goHome", sender: nil)
                }
            }
        }
    }
}
