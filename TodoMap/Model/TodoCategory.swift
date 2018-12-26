//
//  TodoCategory.swift
//  TodoMap
//
//  Created by Aljaz Kern on 18/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import Foundation

class TodoCategory {
    
    var name : String
    var id : String
    var color : String
    var share : Bool
    var mode : String
    var userID : String
    var categoryID : String
    
    init(name1: String, id1: String, color1: String, share1:Bool = false, mode1:String = "", usrID:String = "", catID:String = "") {
        name = name1
        id = id1
        color = color1
        share = share1
        mode = mode1
        userID = usrID
        categoryID = catID
    }
}
