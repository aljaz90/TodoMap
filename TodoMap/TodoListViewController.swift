//
//  ViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 07/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TodoListViewController: UITableViewController {

    var testItemArray : [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTodos()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testItemArray.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        cell.textLabel?.text = testItemArray[indexPath.row]["text"] as? String
        if testItemArray[indexPath.row]["done"] as! Bool {
            cell.accessoryType = .checkmark
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todo_id = testItemArray[indexPath.row]["id"] as! String
        let db = Database.database().reference().child("Todos").child(todo_id)
        var res : Bool = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        if testItemArray[indexPath.row]["done"] as! Bool {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            res = false
            
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            res = true
        }
        testItemArray[indexPath.row]["done"] = res
        db.updateChildValues(["done":res])
    }
    
    func getTodos() {
        let db = Database.database().reference().child("Todos")
        SVProgressHUD.show()
        db.observe(.childAdded) { (snapshot) in
            
            let data = snapshot.value as! NSDictionary
            let todo : [String:Any] = ["id": snapshot.key, "text": data["text"]!, "done": data["done"]!]
            self.testItemArray.append(todo)
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Todo", message: "Enter a Todo", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Todo", style: .default) { (action) in
            //self.testItemArray.append(textField.text!)
            //self.tableView.reloadData()
            let db = Database.database().reference().child("Todos")
            let todo = ["text": textField.text!, "done": false] as [String : Any]
            db.childByAutoId().setValue(todo){
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Todo Saved")
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
    

}

