//
//  MessageObject.swift
//  XmppDemoSwift
//
//  Created by Carlos on 5/10/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//
import UIKit
import Foundation
class MessageObject: NSObject, NSCoding{
    
    var senderId: String
    var senderDisplayName: String
    var date: NSDate
    var isMediaMessage: Bool
    var text: String
    var urlImage: String
    var tipoMensaje: NSInteger
    
    init(senderId: String, senderDisplayName: String, date: NSDate, isMediaMessage: Bool, text: String, urlImage: String, tipoMensaje: NSInteger) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.isMediaMessage = isMediaMessage
        self.text = text
        self.urlImage = urlImage
        self.tipoMensaje = tipoMensaje
        
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        self.senderId = aDecoder.decodeObjectForKey("senderId") as! String
        self.senderDisplayName = aDecoder.decodeObjectForKey("senderDisplayName") as! String
        self.date = aDecoder.decodeObjectForKey("date") as! NSDate
        self.isMediaMessage = aDecoder.decodeObjectForKey("isMediaMessage") as! Bool
        self.text = aDecoder.decodeObjectForKey("text") as! String
        self.urlImage = aDecoder.decodeObjectForKey("urlImage") as! String
        self.tipoMensaje = aDecoder.decodeIntegerForKey("tipoMensaje")
       // image = aDecoder.decodeObjectForKey("image") as! String
       
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(senderId, forKey: "senderId")
        aCoder.encodeObject(senderDisplayName, forKey: "senderDisplayName")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(isMediaMessage, forKey: "isMediaMessage")
        aCoder.encodeObject(text, forKey: "text")
        aCoder.encodeObject(urlImage, forKey: "urlImage")
        aCoder.encodeObject(tipoMensaje, forKey: "tipoMensaje")
        

        
    }
 
}
