//
//  UnderlineTextField.swift
//  TodoMap
//
//  Created by Aljaz Kern on 04/12/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import UIKit
import ReactiveKit

class UnderlineTextField: UITextField {
    
    @IBOutlet weak var underlineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        underlineView.backgroundColor = UIColor.lightGray
        
        // Highlight/unhighlight the underlined view when it's being edited.
        reactive.controlEvents(.editingDidBegin).map { _ in
            return UIColor.green
            }.bind(to: underlineView.reactive.backgroundColor).dispose(in: reactive.bag)
        
        reactive.controlEvents(.editingDidEnd).map { _ in
            return UIColor.lightGray
            }.bind(to: underlineView.reactive.backgroundColor).dispose(in: reactive.bag)
    }

}
