//
//  AccountViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 12/12/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

//    @IBOutlet weak var firstNameLabel: UILabel!
//    @IBOutlet weak var lastNameLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var user: UIView!
    @IBOutlet weak var noUser: UIView!
    @IBOutlet weak var orLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Adding UI Color Gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.randomFlat.cgColor, UIColor.randomFlat.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

        self.view.layer.insertSublayer(gradient, at: 0)
        // MARK: - Showing View If User is Present

        if Auth.auth().currentUser != nil {
            
        } else {
            

        }
        
        orLabel.layer.cornerRadius = orLabel.frame.height/2
        orLabel.layer.masksToBounds = false
        orLabel.clipsToBounds = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
