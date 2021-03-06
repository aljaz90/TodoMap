//
//  CategoryViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 17/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class CategoryViewController: SwipeTableViewController, ModalTransitionListener {
    
    func popoverDismissed() {
//        if Auth.auth().currentUser != nil && categoryArray.isEmpty {
//            getData()
//        }
//        else if Auth.auth().currentUser == nil {
//            di
//            categoryArray = []
//            tableView.reloadData()
//            Toast().show(view: self.view, message: "Please Log In", backgroundColor: UIColor.orange, time: 30.0)
//        }
    }
    
    var categoryArray : [TodoCategory] = []
    var shares : [Share] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        if Auth.auth().currentUser != nil {
            // Setting up Firebase DB offline
            let todosRef = Database.database().reference(withPath: "Users/\(Auth.auth().currentUser?.uid ?? "")")
            todosRef.keepSynced(true)
            tableView.delegate = self
            getData()
        }
        else {
            dismiss(animated: true, completion: nil)
            //Toast().show(view: self.view, message: "Please Log In", backgroundColor: UIColor.orange, time: 30.0)
        }

        tableView.separatorStyle = .none
    }
    
    // MARK: - Getting data from DB
    
    func getData(){
        let db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories")
        let shared_db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("sharedCategories")
        
        shared_db.observe(.childAdded) { (snapshot) in
            let data = snapshot.value as! NSDictionary
            
            let email = data["user_email"] as? String ?? ""
            let mode = data["mode"] as? String ?? "mode"
            let user_id = data["user_id"] as? String ?? ""
            let category_id = data["category_id"] as? String ?? ""
            
            if (!email.isEmpty && !mode.isEmpty && !user_id.isEmpty && !category_id.isEmpty) {
                self.getSharedData(share: Share(email1: email, usrID: user_id, mode1: mode, catID: category_id))
            }
            
        }
        
        db.observe(.childAdded) { (snapshot) in
            let data = snapshot.value as! NSDictionary
            self.categoryArray.append(TodoCategory(name1: data["name"] as? String ?? "Null", id1: snapshot.key, color1: data["color"] as? String ?? "#FFFFFF"))
            self.tableView.reloadData()
        }
    }
    
    func getSharedData(share:Share) {
        let share_data_db = Database.database().reference().child("Users").child(share.userUID).child("Categories")
        
        share_data_db.observe(.childAdded) { (snapshot) in
            
            let data = snapshot.value as! NSDictionary
            if snapshot.key == share.categoryID {
                self.categoryArray.append(TodoCategory(name1: data["name"] as? String ?? "Null", id1: snapshot.key, color1: data["color"] as? String ?? "#FFFFFF", share1: true, mode1: share.mode, usrID: share.userUID, catID: share.categoryID))
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - Create Todo - Show alert and push to DB

    @IBAction func addCategory(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Category", message: "Enter a Name", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            if (Auth.auth().currentUser == nil){
                self.dismiss(animated: true, completion: nil)
                //Toast().show(view: self.view, message: "Please Log In", backgroundColor: UIColor.orange)
                return
            }
            
            let db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories")
            let todo = ["name": textField.text!, "color": UIColor.randomFlat.hexValue()] as [String : Any]
            db.childByAutoId().setValue(todo){
                (error, reference) in
                if error != nil {
                    print(error!)
                    Toast().show(view: self.view, message: "Error Creating Category", backgroundColor: UIColor.red)
                } else {
                    Toast().show(view: self.view, message: "Category Created")
                }
            }
            
        }
        alert.addTextField { (alertTxt) in
            alertTxt.placeholder = "Enter Category Name"
            textField = alertTxt
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - UITableview Init methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        super.setCell()
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color)
        let tintColor = ContrastColorOf(backgroundColor ?? UIColor.black, returnFlat: true)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.textLabel?.font = cell.textLabel!.font.withSize(23)
        cell.tintColor = tintColor
        cell.accessoryView?.tintColor = tintColor
        
        if categoryArray[indexPath.row].share {
            print(categoryArray[indexPath.row].mode)
            cell.imageView?.image = UIImage(named: categoryArray[indexPath.row].mode)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodos", sender: self)
        
    }
    
    //MARK: - Preparing for seque to todosView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodos" {
            let todoVC = segue.destination as! TodoListViewController
            //todoVC.categoryID = senderData
            if let indexPath = tableView.indexPathForSelectedRow {
                todoVC.category = categoryArray[indexPath.row]
            }
            
        }
    }
    
    // MARK: - Updating model after deletion from DB
    
    override func updateModel(at indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            Toast().show(view: self.view, message: "Please Log In", backgroundColor: UIColor.orange)
            return
        }
        
        if !categoryArray[indexPath.row].share {
            
            let db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories")
            if let categoryForDeletion = self.categoryArray[indexPath.row].id as String? {
                db.child(categoryForDeletion).removeValue(){
                    (error, ref) in
                    if error != nil {
                        print("Something went wrong deleting category: \(error!)")
                    }
                    
                }
                
                self.categoryArray.remove(at: indexPath.row)
            }
        } else {
            Toast().show(view: self.view, message: "I'm afraid I can't let you do that.", backgroundColor: UIColor.red)
        }
        
    }
    
    
}

