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

class TodoListViewController: UITableViewController, UISearchBarDelegate {
    
    let toast = Toast()
    
    @IBOutlet weak var navigation: UINavigationItem!
    var itemArray : [Todo] = []
    var category : TodoCategory? {
        didSet{
            getTodos()
            navigation.title = category?.name
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let todosRef = Database.database().reference(withPath: "Todos")
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.toast.show(view: self.view, message: "Connected!", backgroundColor: UIColor.green)
                //self.showToast(message: "Connected!", backgroundColor: UIColor.green)
            } else {
                self.toast.show(view: self.view, message: "Disconnected!", backgroundColor: UIColor.red)
            }
        })
        
        todosRef.keepSynced(true)
        //getTodos()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].text
        cell.accessoryType = (itemArray[indexPath.row].done) ? .checkmark : .none
        cell.tintColor = UIColor.black
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todo_id = itemArray[indexPath.row].id
        print(todo_id)
        let db = Database.database().reference().child("Todos").child(todo_id)
        
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        db.updateChildValues(["done": itemArray[indexPath.row].done])
        tableView.reloadData()
    }
    
    func getTodos() {
        
        let db = Database.database().reference().child("Todos")
        SVProgressHUD.show()
        db.observe(.value) { (snapshot) in
            if !snapshot.hasChildren(){
                
                self.toast.show(view: self.view, message: "You dont have any todos. Hmm… Maybe you should Create some.", backgroundColor: UIColor.blue, time: 10.0)
                SVProgressHUD.dismiss()
            }
            return;
        }
        
        
        db.observe(.childAdded) { (snapshot) in
            if !(snapshot.hasChildren()) {
                SVProgressHUD.dismiss()
                
                return;
            }
            let data = snapshot.value as! NSDictionary
            print("INFO: \(data)")
            let todo = Todo(text1: data["text"] as? String ?? "Nil", id1: snapshot.key, done1: data["done"] as? Bool ?? false, categoryID1: data["categoryID"] as? String ?? "IDK")
            
            if data["categoryID"] as? String == self.category?.id {
                self.itemArray.append(todo)
            }
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Todo", message: "Enter a Todo", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Todo", style: .default) { (action) in
            
            let db = Database.database().reference().child("Todos")
            let todo = ["text": textField.text!, "done": false, "categoryID": self.category?.id ?? "no-cat"] as [String : Any]
            db.childByAutoId().setValue(todo){
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    self.toast.show(view: self.view, message: "Todo Created")
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let strSearch = searchText.lowercased()
        
        if strSearch.isEmpty {
            itemArray = []
            getTodos()
            return;
        }
        
        let newArray = itemArray.filter { $0.text.lowercased().contains(strSearch) }
        itemArray = newArray
        tableView.reloadData()
        
    }
    /* Search Bar Animation and Search */
    /*
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.navigationItem.titleView = searchBar
        
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = 1
        }
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.title = "Hello"
        UIView.animate(withDuration: 0.2) {
            self.searchBar.alpha = 0
        }
        
    }
    
    func createSearchBar(){
        
        searchBar.alpha = 0
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search for Todos"
        searchBar.delegate = self
        
        
    }
    */
}

