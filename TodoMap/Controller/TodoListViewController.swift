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
import ChameleonFramework

class TodoListViewController: SwipeTableViewController, UISearchBarDelegate {
    
    let toast = Toast()
    var db : DatabaseReference = Database.database().reference()
    
    @IBOutlet weak var navigation: UINavigationItem!
    var itemArray : [Todo] = []
    var category : TodoCategory? {
        didSet{
            db = Database.database().reference().child("Categories").child(category?.id ?? "NIL").child("Todos")
            getTodos()
            navigation.title = category?.name
            navigationController?.navigationBar.barTintColor = UIColor(hexString: category?.color ?? "#4682b4")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let todosRef = Database.database().reference(withPath: "Categories")
        todosRef.keepSynced(true)
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.toast.show(view: self.view, message: "Connected!", backgroundColor: UIColor.green)
                //self.showToast(message: "Connected!", backgroundColor: UIColor.green)
            } else {
                self.toast.show(view: self.view, message: "Disconnected!", backgroundColor: UIColor.red)
            }
        })
        
        
        //getTodos()
    }
    // MARK: - Default Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].text
        cell.accessoryType = (itemArray[indexPath.row].done) ? .checkmark : .none
        let backgrgoundColor = UIColor.init(hexString: category?.color ?? "#000000")?.lighten(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count))
        cell.backgroundColor = backgrgoundColor

        cell.textLabel?.textColor = ContrastColorOf(backgrgoundColor!, returnFlat: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todo_id = itemArray[indexPath.row].id
        
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        db.child(todo_id).updateChildValues(["done": itemArray[indexPath.row].done])
        tableView.reloadData()
    }

    // MARK: - Getting todos from DB
    
    func getTodos() {
        
        SVProgressHUD.show()
        db.observe(.value) { (snapshot) in
            if !snapshot.hasChildren(){
                SVProgressHUD.dismiss()
            }
            return;
        }
        
        
        db.observe(.childAdded) { (snapshot) in
            
            let data = snapshot.value as! NSDictionary
            let todo = Todo(text1: data["text"] as? String ?? "Nil", id1: snapshot.key, done1: data["done"] as? Bool ?? false)
            
            self.itemArray.append(todo)
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Todo", message: "Enter a Todo", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Todo", style: .default) { (action) in
            
            
            let todo = ["text": textField.text!, "done": false] as [String : Any]
            self.db.childByAutoId().setValue(todo){
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
    
    // MARK: - Deleting Todo
    override func updateModel(at indexPath: IndexPath) {
        
        if let todoForDeletion = self.itemArray[indexPath.row].id as String? {
            db.child(todoForDeletion).removeValue(){
                (error, ref) in
                if error != nil {
                    print("Something went wring deleting todo: \(error!)")
                }
            }
            
            self.itemArray.remove(at: indexPath.row)
        }
    }
}

