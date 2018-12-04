//
//  SignUpViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 27/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import ReactiveKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

//        let gradient: CAGradientLayer = CAGradientLayer()
//
//        gradient.colors = [UIColor.randomFlat.cgColor, UIColor.randomFlat.cgColor]
//        gradient.locations = [0.0 , 1.0]
//        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
//        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//
//        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUser(){
        
        let email = emailField.text
        let password = passwordField.text
        
        print(email ?? "nil")
        print(password ?? "nil")
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//            // ...
//            guard let user = authResult?.user else { return }
//        }
    }
    
    
    
    
}
