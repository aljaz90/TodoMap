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
    var search = true
    var db : DatabaseReference = Database.database().reference()
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var navigation: UINavigationItem!
    var itemArray : [Todo] = []
    var category : TodoCategory? {
        didSet{
            db = Database.database().reference().child("Categories").child(category?.id ?? "NIL").child("Todos")
            getTodos()
            navigation.title = category?.name
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = category?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            if let barTintColor = UIColor(hexString: colorHex) {
                navBar.barTintColor = UIColor(hexString: colorHex)
                let tintColor = ContrastColorOf(barTintColor, returnFlat: true)
                navBar.tintColor = tintColor
                if #available(iOS 11.0, *) {
                    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor]
                } else {
                    // Fallback on earlier versions
                }
            }
            
            
        }
    }
    
    // MARK: - Default Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: - Initializing cell in Table View
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let data = itemArray[indexPath.row]
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: data.text)
        var accessory : UITableViewCell.AccessoryType = .none
        let categoryBackgroundColor = UIColor(hexString: category?.color ?? "#000000")
        var backgroundColor = UIColor.white
        
        if ContrastColorOf(categoryBackgroundColor ?? UIColor(hexString: "#ffffff")!, returnFlat: true) == UIColor.flatWhite {
            backgroundColor = (categoryBackgroundColor?.lighten(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)))!
        } else {
            backgroundColor = (categoryBackgroundColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)))!
        }
        let tintColor = ContrastColorOf(backgroundColor, returnFlat: true)
        
        // MARK: - Checking if Todo is Completed
        
        if data.done {
            accessory = .checkmark
            backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        cell.textLabel?.attributedText = attributeString
        
        // MARK: - Animating
        
        UIView.animate(withDuration: 0.4) {
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = tintColor
            cell.tintColor = tintColor
            cell.accessoryType = accessory
        }
        
        
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
        
        search = false
        searchBar.placeholder = "Add a new Todo"
        searchBar.barTintColor = UIColor.red
//        var textField = UITextField()
//        let alert = UIAlertController(title: "Add a Todo", message: "Enter a Todo", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Add Todo", style: .default) { (action) in
//
//
//            let todo = ["text": textField.text!, "done": false] as [String : Any]
//            self.db.childByAutoId().setValue(todo){
//                (error, reference) in
//                if error != nil {
//                    print(error!)
//                } else {
//                    self.toast.show(view: self.view, message: "Todo Created")
//                }
//            }
//
//        }
//        alert.addTextField { (alertTxt) in
//            alertTxt.placeholder = "Enter Todo"
//            textField = alertTxt
//        }
//
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !search {
            print(searchBar.text!)
            search = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if search {
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
        
    }
    // TODO: Connect searchbar and create todo
    
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

