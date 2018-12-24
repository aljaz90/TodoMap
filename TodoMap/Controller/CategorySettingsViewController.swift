//
//  CategorySettingsViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 23/12/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit

class CategorySettingsViewController: SwipeTableViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var addView: UIView!
    
    var mode = ""
    var shares : [Share] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shares.append(Share(email1: "example@example.com", catUID: "dsaasdas", mode1: "edit"))
        
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
        if !mode.isEmpty && !email.isEmpty {
            
        }
    }
}
