//
//  LogInViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 27/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addLineToView(view: emailField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 2.0)
        addLineToView(view: passwordField, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 2.0)
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.randomFlat.cgColor, UIColor.randomFlat.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.enablesReturnKeyAutomatically = true
        passwordField.enablesReturnKeyAutomatically = true
    }
    
    
    
    @IBAction func logIn(_ sender: Any) {
        if (!(emailField.text!.isEmpty) && !(passwordField.text!.isEmpty)) {
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (result, error) in
                if error != nil {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .userNotFound:
                            print("User not found")
                            Toast().show(view: self.view, message: "User not Found", backgroundColor: UIColor.red)
                            break
                        case .wrongPassword:
                            print("Wrong password")
                            Toast().show(view: self.view, message: "Wrong Password", backgroundColor: UIColor.red)
                            break
                        case .userDisabled:
                            print("User Disabled")
                            Toast().show(view: self.view, message: "User Disabled", backgroundColor: UIColor.yellow)
                            break
                        case .networkError:
                            print("No Connection")
                            Toast().show(view: self.view, message: "Not Connected", backgroundColor: UIColor.red)
                            break
                            
                        default:
                            print("Create User Error: \(error!)")
                            Toast().show(view: self.view, message: "Error \(error!)", backgroundColor: UIColor.red)
                        }
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == passwordField {
            logIn(self)
        } else {
            passwordField.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
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
