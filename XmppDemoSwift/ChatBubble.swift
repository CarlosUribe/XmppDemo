//
//  ChatBubble.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 12/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import UIKit

protocol BubbleButtonActionsProtocol {
    
    func accionBotonPideCelular(sender: UIButton)
    
    
}


class ChatBubble: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    
    // Properties
    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    //var buttonViewChat: UIButton?
    var buttonFrameSizeY: CGFloat = 0.0
    var buttonFrameSizeX: CGFloat = 0.0
    //var textViewChat: UITextView?
    var tituloBoton: String?
    var tipoAccionBoton: Int = 0
    var delegate: BubbleButtonActionsProtocol!
    //var textViewData: String?
    /**
     Initializes a chat bubble view
     
     - parameter data:   ChatBubble Data
     - parameter startY: origin.y of the chat bubble frame in parent view
     
     - returns: Chat Bubble
     */
    init(data: ChatBubbleData, startY: CGFloat){
        
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(data.type, startY:startY))
        
        // Making Background transparent
        self.backgroundColor = UIColor.clearColor()
        
        let padding: CGFloat = 10.0
        
        
        // 2. Drawing image if any
        if let chatImage = data.image {
            
            let width: CGFloat = min(chatImage.size.width, CGRectGetWidth(self.frame) - 2 * padding)
            let height: CGFloat = chatImage.size.height * (width / chatImage.size.width)
            imageViewChat = UIImageView(frame: CGRectMake(padding, padding, width, height))
            imageViewChat?.image = chatImage
            imageViewChat?.layer.cornerRadius = 5.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
        }
//        if let chatTextView = data.textView {
//            let width: CGFloat = min(chatTextView.frame.size.width, CGRectGetWidth(self.frame) - 2 * padding)
//            let height: CGFloat = chatTextView.frame.size.height * (width / chatTextView.frame.size.width)
//            textViewChat = UITextView(frame: CGRectMake(padding, padding, width, height))
//            textViewChat?.text = data.textViewData
//            textViewChat?.layer.cornerRadius = 5.0
//            textViewChat?.layer.masksToBounds = true
//            self.addSubview(textViewChat!)
//            data.text = nil
//        }
        
        if (data.text != nil) {
            // frame calculation
            let startX = padding + 10
            var startY:CGFloat = 10.0
            if (imageViewChat != nil) {
                startY += CGRectGetMaxY(imageViewChat!.frame)
            }
            labelChatText = UILabel(frame: CGRectMake(startX, startY, CGRectGetWidth(self.frame) - 2 * startX , 5))
            labelChatText?.textAlignment = data.type == .USER ? .Right : .Left
            labelChatText?.font = UIFont.systemFontOfSize(13)
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            labelChatText?.sizeToFit() // Getting fullsize of it
            self.addSubview(labelChatText!)
        }

        if (data.button != []) {
            let startX = padding
            var startY:CGFloat = 5.0
            if (labelChatText != nil) {
                startY += CGRectGetMaxY(labelChatText!.frame)
            }
            let backButtonImage = UIImage(named: "line")
            var i: Int = 0
            for var buttonViewChat in data.button {
                
                tituloBoton = data.tituloBoton[i]
                buttonViewChat = UIButton(frame: CGRectMake(startX, startY + 10, CGRectGetWidth(self.frame) * 1.1, 30))
                buttonViewChat.setTitle(tituloBoton, forState: .Normal)
                buttonViewChat.setTitleColor(UIColor.blueColor(), forState: .Normal)
                buttonViewChat.layer.masksToBounds = true
                buttonViewChat.layer.cornerRadius = 5.0
                buttonViewChat.enabled = true
                buttonViewChat.setBackgroundImage(backButtonImage, forState: .Normal)
                tipoAccionBoton = data.tipoAccionBoton!
                switch tipoAccionBoton {
                case 1:
                    buttonViewChat.addTarget(self, action: #selector(buttonPress(_:)), forControlEvents: .TouchUpInside)
                    
                default:
                    
                    break//buttonViewChat!.addTarget(self, action: <#T##Selector#>, forControlEvents: <#T##UIControlEvents#>)
                    
                }
                
                self.addSubview(buttonViewChat)
                bringSubviewToFront(buttonViewChat)
                self.buttonFrameSizeY += CGRectGetMaxY(buttonViewChat.frame)
                self.buttonFrameSizeX += CGRectGetMaxX(buttonViewChat.frame)
                startY += CGRectGetMaxY(buttonViewChat.frame)
                i += 1
            }
            
        }
        
        // 3. Going to add Text if any
               // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if (imageViewChat != nil) {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max(CGRectGetMaxX(imageViewChat!.frame), CGRectGetMaxX(labelChatText!.frame)) + padding
            viewHeight = max(CGRectGetMaxY(imageViewChat!.frame), CGRectGetMaxY(labelChatText!.frame)) + padding
            
        } else if (data.text != nil && data.button != []){
            viewWidth = max(CGRectGetMaxX(labelChatText!.frame), buttonFrameSizeX) + padding
            viewHeight = max(CGRectGetMaxY(labelChatText!.frame), buttonFrameSizeY) + padding
            
        }else {
            viewHeight = CGRectGetMaxY(labelChatText!.frame) + padding/2
            viewWidth = CGRectGetWidth(labelChatText!.frame) + CGRectGetMinX(labelChatText!.frame) + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), viewWidth, viewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName: String!
        switch data.type {
        case .USER:
            bubbleImageFileName = "bubbleUser"
        case .GUS:
            bubbleImageFileName = "bubbleGus"
        case .ACTION:
            bubbleImageFileName = "bubbleAction"
        }
        imageViewBG = UIImageView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        if data.type == .USER {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 22, 17, 20))
        }

        self.addSubview(imageViewBG!)
        self.sendSubviewToBack(imageViewBG!)
        
        // Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.type == .USER ? 0.0 : -8.0
        let bgImageNewX = CGRectGetMinX(imageViewBG!.frame) + repsotionXFactor
        let bgImageNewWidth =  CGRectGetWidth(imageViewBG!.frame) + CGFloat(12.0)
        let bgImageNewHeight =  CGRectGetHeight(imageViewBG!.frame) + CGFloat(6.0)
        imageViewBG?.frame = CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)
        
                // Keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .USER {
            // Need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = CGRectGetWidth(imageViewBG!.frame)
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -CGRectGetMinX(imageViewBG!.frame) + 3
        }
        
        self.frame = CGRectMake(newStartX,CGRectGetMinY(self.frame), CGRectGetWidth(frame), CGRectGetHeight(frame))
        let shadowLayer = UIView(frame: CGRectMake((imageViewBG?.frame.origin.x)!, (imageViewBG?.frame.origin.y)!, (imageViewBG?.frame.size.width)! + 20, (imageViewBG?.frame.size.width)! + 20))
        shadowLayer.backgroundColor = UIColor.clearColor()
        shadowLayer.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 13).CGColor
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: imageViewBG!.bounds, cornerRadius: 12).CGPath
        shadowLayer.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.layer.shadowOpacity = 0.3
        shadowLayer.layer.shadowRadius = 5
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false
        
        self.addSubview(shadowLayer)
        self.sendSubviewToBack(shadowLayer)

    }
    
    // 6. View persistance support
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FRAME CALCULATION
    class func framePrimary(type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .USER ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }
    
    //FUNCION DE BOTONES
    func buttonPress(button:UIButton) {
        delegate.accionBotonPideCelular(button)
    }

   
    
}
