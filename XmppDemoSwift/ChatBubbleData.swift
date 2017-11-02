//
//  ChatBubbleData.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 12/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//


import Foundation
import UIKit 
// 1. Type Enum
/**
 Enum specifing the type
 
 - Mine:     Chat message is outgoing
 - Opponent: Chat message is incoming
 */
enum BubbleDataType: Int{
    case USER = 0
    case GUS
    case ACTION
}

class ChatBubbleData {
    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: NSDate?
    var button: [UIButton] = []
    //var textView: UITextView?
    var tituloBoton: [String] = []
    var tipoAccionBoton: Int?
    //var textViewData: String?
    var type: BubbleDataType
    
    // 3. Initialization
    init(text: String?,image: UIImage?,date: NSDate? , button: [UIButton], tituloBoton: [String], tipoAccionBoton: Int?, type: BubbleDataType?) {
        self.text = text
        self.image = image
        self.date = date
        self.button = button
       // self.textView = textView
        self.tituloBoton = tituloBoton
        self.tipoAccionBoton = tipoAccionBoton
       // self.textViewData = textViewData
        self.type = type!
    }
}