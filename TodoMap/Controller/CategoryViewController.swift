//
//  CategoryViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 17/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import Firebase

class CategoryViewController: UITableViewController {
    
    var categoryArray : [TodoCategory] = []
    let toast = Toast()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let todosRef = Database.database().reference(withPath: "Categories")
        
        todosRef.keepSynced(true)
        getData()
    }
    
    func getData(){
        let db = Database.database().reference().child("Categories")
        db.observe(.childAdded) { (snapshot) in
            let data = snapshot.value as! NSDictionary
            self.categoryArray.append(TodoCategory(name1: data["name"] as! String, id1: snapshot.key))
            self.tableView.reloadData()
        }
    }
/*
     Create Todo - Show alert and push to DB
*/
    @IBAction func addCategory(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Category", message: "Enter a Name", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //self.itemArray.append(textField.text!)
            //self.tableView.reloadData()
            let db = Database.database().reference().child("Categories")
            let todo = ["name": textField.text!] as [String : Any]
            db.childByAutoId().setValue(todo){
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Category Saved")
                    //self.showToast(message: "Category Created")
                }
            }
            
        }
        alert.addTextField { (alertTxt) in
            alertTxt.placeholder = "Enter Todo"
            textField = alertTxt
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodos", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodos" {
            let todoVC = segue.destination as! TodoListViewController
            //todoVC.categoryID = senderData
            if let indexPath = tableView.indexPathForSelectedRow {
                todoVC.category = categoryArray[indexPath.row]
            }
            
        }
    }
}
