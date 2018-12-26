//
//  Share.swift
//  TodoMap
//
//  Created by Aljaz Kern on 24/12/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import Foundation

class Share {
    
    var email : String
    var userUID : String
    var mode : String
    var categoryID : String
    
    init(email1:String, usrID:String, mode1:String, catID:String) {
        email = email1
        userUID = usrID
        mode = mode1
        categoryID = catID
    }
    
}
