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
    
    var search = true
    var db : DatabaseReference = Database.database().reference()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var navigation: UINavigationItem!
    
    var itemArray : [Todo] = []
    var category : TodoCategory? {
        didSet{
            if (Auth.auth().currentUser == nil){
                return
            }
            
            if category?.share ?? false {
                settingButton.isEnabled = false
                db = Database.database().reference().child("Users").child(category?.userID ?? "").child("Categories").child(category?.categoryID ?? "NIL").child("Todos")
            } else {
                db = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories").child(category?.id ?? "NIL").child("Todos")
            }
            
            getTodos()
            navigation.title = category?.name
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                Toast().show(view: self.view, message: "Connected!", backgroundColor: UIColor.green)
            } else {
                Toast().show(view: self.view, message: "Disconnected!", backgroundColor: UIColor.red)
            }
        })
        
        if (Auth.auth().currentUser == nil){
            Toast().show(view: self.view, message: "Please Log In", backgroundColor: UIColor.orange, time: 30.0)
            dismiss(animated: true, completion: nil)
            return
        }
        
        if (category?.mode == "view") {
            addButton.isEnabled = false
        }
        
        //let todosRef = Database.database().reference(withPath: "Users").child(Auth.auth().currentUser?.uid ?? "").child("Categories")
        db.keepSynced(true)
        tableView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
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
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print("##################")
                print("pressed \(indexPath)")
                print(itemArray[indexPath[1]].text)
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    
    // MARK: - Default Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: - Initializing cell in Table View
        super.setCell()
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
        
        if (!(category?.share ?? false) || category?.mode == "edit") {
            let todo_id = itemArray[indexPath.row].id
            
            
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            db.child(todo_id).updateChildValues(["done": itemArray[indexPath.row].done])
            tableView.reloadData()
        } else {
            Toast().show(view: self.view, message: "I'm afraid I can't let you do that.", backgroundColor: UIColor.red)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }

    // MARK: - Getting todos from DB
    
    func getTodos() {
        
        SVProgressHUD.show()
        
        // MARK: - Checking if DB is empty
        
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
        
        if search && (category?.mode == "edit" || !(category?.share ?? false)){
            search = false
            searchBar.placeholder = "Add a new Todo"
//            searchBar.barTintColor = UIColor(hexString: category?.color ?? "#ffffff")
//            searchBar.backgroundColor = UIColor(hexString: category?.color ?? "#ffffff")
//            searchBar.tintColor = UIColor(hexString: "#ffffff")
            searchBar.becomeFirstResponder()
            searchBar.showsCancelButton = true
        }
        else if category?.mode == "view"{
            Toast().show(view: self.view, message: "You can Only View Todos", backgroundColor: UIColor.red)
        } else {
            search = true
            searchBar.placeholder = "Search"
            searchBar.barTintColor = UIColor(hexString: "#ffffff")
            searchBar.backgroundColor = UIColor(hexString: "#ffffff")
            searchBar.tintColor = UIColor.darkGray
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
        
        
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
//                    Toast().show(view: self.view, message: "Todo Created")
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search = true
        searchBar.placeholder = "Search"
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !search && (category?.mode == "edit" || !(category?.share ?? false)) {
            print(searchBar.text!)
            if !(searchBar.text!.isEmpty){
                let todo = ["text": searchBar.text!, "done": false] as [String : Any]
                self.db.childByAutoId().setValue(todo){
                    (error, reference) in
                    if error != nil {
                        print(error!)
                        Toast().show(view: self.view, message: "Something Went Wrong", backgroundColor: UIColor.red)
                    } else {
                        searchBar.text = ""
                        Toast().show(view: self.view, message: "Todo Created", backgroundColor: UIColor.green)
                        
                    }
                }
            }
            
            search = true
            searchBar.placeholder = "Search"
            searchBar.showsCancelButton = false
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
        
        if !(category?.share ?? false) || category?.mode == "edit" {
            if let todoForDeletion = self.itemArray[indexPath.row].id as String? {
                db.child(todoForDeletion).removeValue(){
                    (error, ref) in
                    if error != nil {
                        print("Something went wring deleting todo: \(error!)")
                    }
                }
                
                self.itemArray.remove(at: indexPath.row)
            }
        } else {
            Toast().show(view: self.view, message: "I'm afraid I can't let you do that.", backgroundColor: UIColor.red)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategorySettings" {
            let settingsVC = segue.destination as! CategorySettingsViewController
            
            if category != nil {
                settingsVC.category = category
            }
            
        }
    }
}

