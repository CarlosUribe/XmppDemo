//
//  Extensions.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 18/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import Foundation
import UIKit
import XMPPFramework


//DIRECCIONES PARA SERVICIOS
let HOST_SERVICE: String = ""
let WEB_SMS_CODE_VERIFICATION: String = ""
let WEB_PHONE_VERIFICATION: String = ""




func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}


protocol ContactPickerDelegate{
    func didSelectContact(recipient: XMPPUserCoreDataStorageObject)
}

func shake(view:UIView){
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
    animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
    view.layer.addAnimation(animation, forKey: "position")

}

