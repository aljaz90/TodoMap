//
//  CategorySettingsViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 23/12/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import Firebase

class CategorySettingsViewController: SwipeTableViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var addView: UIView!
    var db : DatabaseReference = Database.database().reference()
    
    var category : TodoCategory? {
        didSet {
            if Auth.auth().currentUser != nil {
                db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories").child(category?.id ?? "NIL").child("sharedUsers")
                getShares()
            }
        }
    }
    
    var mode = ""
    var shares : [Share] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            dismiss(animated: true, completion: nil)
            return
        }
        
        addView.layer.borderWidth = 1.0
        addView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    @IBAction func setViewing(_ sender: Any) {
        mode = "view"
        UIView.animate(withDuration: 0.5) {
            self.viewButton.backgroundColor = UIColor.gray
            self.editButton.backgroundColor = UIColor.white
        }
    }
    
    func getShares() {
        db.observe(.childAdded) { (snapsnot) in
            let data = snapsnot.value as! NSDictionary
            
            self.shares.append(Share(email1: data["user_email"] as? String ?? "", usrID: data["user_uid"] as? String ?? "", mode1: data["mode"] as? String ?? "", catID: ""))
        }
    }
    
    @IBAction func setEdit(_ sender: Any) {
        mode = "edit"
        UIView.animate(withDuration: 0.5) {
            self.viewButton.backgroundColor = UIColor.white
            self.editButton.backgroundColor = UIColor.gray
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shares.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.setCell(cellID: "ShareCell")
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let share = shares[indexPath.row]
        cell.imageView?.image = UIImage(named: share.mode)
        cell.textLabel?.text = share.email
        return cell
    }
    
    @IBAction func addUser(_ sender: Any) {
        let email = emailField.text ?? ""
        var found = false
        
        if !mode.isEmpty && isValidEmail(testStr: email) {
            let databaseRef = Database.database().reference()
            
            databaseRef.child("Users").observe(.childAdded) { (snapshot) in
                
                let data = snapshot.value as! NSDictionary
                
                if (data["email"] as? String ?? "" == email) {
                    
                    self.createBinding(email: email, db_email: data["email"] as? String ?? "", db_uid: snapshot.key, mode: self.mode)
                    found = true
                    
                }
            }
//            if !found {
//                Toast().show(view: self.view, message: "No User Found", backgroundColor: UIColor.red)
//            }
            
        }
    }
    
    func createBinding(email:String, db_email:String, db_uid:String, mode:String) {
        if (db_email != Auth.auth().currentUser?.email && !db_email.isEmpty) {
            let user_db = Database.database().reference().child("Users").child(db_uid).child("sharedCategories")
            
            db.child(db_uid).setValue(["user_uid": db_uid, "user_email": db_email, "mode": mode]) {
                (snapshot, error) in
                
//                if error! != nil {
//                    Toast().show(view: self.view, message: "Something Went Wrong", backgroundColor: UIColor.red)
//                } else {
                Toast().show(view: self.view, message: "User Added", backgroundColor: UIColor.green, time: 4.0)
//                }
            }
            
            user_db.child(category?.id ?? "NIL").setValue(["user_id": Auth.auth().currentUser?.uid, "user_email": Auth.auth().currentUser?.email, "category_id": category?.id ?? "NIL", "mode": mode])
            
            
            
        } else {
            Toast().show(view: self.view, message: "Cannot Add Yourself", backgroundColor: UIColor.red, time: 4.0)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
