//
//  Toast.swift
//  TodoMap
//
//  Created by Aljaz Kern on 20/11/2018.
//  Copyright © 2018 Aljaz Kern. All rights reserved.
//

import Foundation
import UIKit

class Toast {
	
    func show(view: UIView,message: String, backgroundColor: UIColor = UIColor.black, color: UIColor = UIColor.white, time: Double = 4.0){
        
		let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 75, y: view.frame.size.height-125, width: 150, height: 35))
        toastLabel.backgroundColor = backgroundColor.withAlphaComponent(0.6)
        toastLabel.textColor = color
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 16.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: time, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
	}
}
