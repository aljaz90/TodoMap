//
//  SwipeTableViewController.swift
//  TodoMap
//
//  Created by Aljaz Kern on 23/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var cellName = "Cell"
    //MARK: - Making TableView cells swipable for deletion
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func setCell(cellID:String = "Cell"){
        cellName = cellID
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        //let db = Database.database().reference().child("Categories")
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    // MARK: - Category and Todo Controllers override this method
    func updateModel(at indexPath: IndexPath) {
        
    }

}
