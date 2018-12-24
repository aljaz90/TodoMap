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
    var categoryUID : String
    var mode : String
    
    init(email1:String, catUID:String, mode1:String) {
        email = email1
        categoryUID = catUID
        mode = mode1
    }
    
}
