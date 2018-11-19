//
//  Todo.swift
//  TodoMap
//
//  Created by Aljaz Kern on 10/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import Foundation

class Todo {
    var done : Bool = false
    var text : String
    var id : String
    var categoryID : String
    
    init(text1: String, id1: String, done1: Bool = false, categoryID1: String) {
        text = text1
        id = id1
        done = done1
        categoryID = categoryID1
    }
}
