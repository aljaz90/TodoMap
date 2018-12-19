//
//  SignUpViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 27/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var toastView: UIView!
    
    let db = Database.database().reference().child("Users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addLineToView(view: lastNameField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
        addLineToView(view: firstNameField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
        addLineToView(view: emailField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 2.0)
        addLineToView(view: passwordField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 2.0)
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [UIColor.randomFlat.cgColor, UIColor.randomFlat.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

        self.view.layer.insertSublayer(gradient, at: 0)
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        switch textField {
            case firstNameField:
                lastNameField.becomeFirstResponder()
                break
            case lastNameField:
                emailField.becomeFirstResponder()
                break
            case emailField:
                passwordField.becomeFirstResponder()
                break
            case passwordField:
                createUser()
                break
        default:
            print("")
        }
        return true
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUser(){
        
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let first_name = firstNameField.text ?? ""
        let last_name = lastNameField.text ?? ""
        
        if (!(email.isEmpty) && !(password.isEmpty) && !(first_name.isEmpty) && !(last_name.isEmpty)) {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if error != nil {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            print("invalid email")
                            Toast().show(view: self.toastView, message: "Invalid Email", backgroundColor: UIColor.red)
                            break
                        case .emailAlreadyInUse:
                            print("in use")
                            Toast().show(view: self.toastView, message: "Email in Use", backgroundColor: UIColor.red)
                            break
                        case .weakPassword:
                            print("password must have at least 6 characters")
                            Toast().show(view: self.toastView, message: "Password is too Short", backgroundColor: UIColor.red)
                            break
                        case .networkError:
                            print("Not Connected")
                            Toast().show(view: self.toastView, message: "Not Connected", backgroundColor: UIColor.red)
                            break
                            
                        default:
                            print("Create User Error: \(error!)")
                            Toast().show(view: self.toastView, message: "Error \(error!)", backgroundColor: UIColor.red)
                        }
                    }
                }
                guard let user = authResult?.user else { return }
                print("STUFF: Doing something?")
                let data = ["email": user.email, "uid": user.uid, "firstName": first_name, "lastName": last_name]
                self.db.child(user.uid).setValue(data)
                user.sendEmailVerification(completion: nil)
                
                self.dismiss(animated: true, completion: nil)
            }

        }
        else {
            Toast().show(view: self.toastView, message: "Fill out All Fields")
        }
    }
    
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
    
    
    
}
