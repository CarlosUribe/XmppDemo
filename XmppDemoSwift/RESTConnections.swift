//
//  RESTConnections.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 31/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit


let user = "apiuser"
let password = "supersecret"
var respuestaPhoneVerification: JSON = nil
var respuestaCodeVerification: JSON = nil
var respuestaEmailVerification: JSON = nil


func sendNumber(cellPhoneField: String){
    var destination = ""
    var deviceChannel = ""
    
    destination += "+52"
    destination += cellPhoneField
    deviceChannel = "sms"
    
    
    let parameters = [
        "destination": destination,
        "deviceChannel": deviceChannel
    ]
    
    let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    let base64Credentials = credentialData.base64EncodedStringWithOptions([])
    let headers = ["Authorization": "Basic \(base64Credentials)"]
    Alamofire.request(.POST, "\(HOST_SERVICE)\(WEB_PHONE_VERIFICATION)", parameters: parameters, encoding: .JSON, headers: headers)
        //.authenticate(user: user, password: password)
        .responseJSON {response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    respuestaPhoneVerification = JSON(value)
                    print("JSON: \(respuestaPhoneVerification)")
                    if respuestaPhoneVerification["error"].string != nil{
                        NSNotificationCenter.defaultCenter().postNotificationName("PhoneError", object: nil)
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName("PhoneValid", object: nil)
                    }
                    
                }
            case .Failure(let error):
                print("\(error) error")
            }
    }
    
    
}

func sendCodeByEmail(email: String){
    var destination = ""
    var deviceChannel = ""
    
    destination = email
    deviceChannel = "email"
    var parse: String = ""
    
    if let idPerson = respuestaPhoneVerification["id"].string{
        parse = idPerson
    }
    
    
    let parameters = [
        "destination": destination,
        "deviceChannel": deviceChannel,
        "idPerson": parse
    ]
    
    let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    let base64Credentials = credentialData.base64EncodedStringWithOptions([])
    let headers = ["Authorization": "Basic \(base64Credentials)"]
    Alamofire.request(.POST, "\(HOST_SERVICE)\(WEB_PHONE_VERIFICATION)", parameters: parameters, encoding: .JSON, headers: headers)
        //.authenticate(user: user, password: password)
        .responseJSON {response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    respuestaEmailVerification = JSON(value)
                    print("JSON: \(respuestaEmailVerification)")
                    if respuestaEmailVerification["error"].string != nil{
                        NSNotificationCenter.defaultCenter().postNotificationName("EmailError", object: nil)
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName("EmailValid", object: nil)
                    }
                    
                }
            case .Failure(let error):
                print("\(error) error")
            }
    }
    
}

func sendCode(textCode: String){
   // var parse:[[String:AnyObject]]!
    var parse: String = ""
//    if let idPerson = respuestaPhoneVerification["id"].arrayObject{
//        parse = idPerson as! [[String:AnyObject]]
//    }
    
    if let idPerson = respuestaPhoneVerification["id"].string{
        parse = idPerson
    }

    

    
    //let elementosUsusario = parse[0]["id"] as? String
   
    let parameters = [
        "idPerson": parse,
        "token": textCode
    ]
    
    let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    let base64Credentials = credentialData.base64EncodedStringWithOptions([])
    let headers = ["Authorization": "Basic \(base64Credentials)"]
    Alamofire.request(.POST, "\(HOST_SERVICE)\(WEB_SMS_CODE_VERIFICATION)", parameters: parameters, encoding: .JSON, headers: headers)
        //.authenticate(user: user, password: password)
        .responseJSON {response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    respuestaCodeVerification = JSON(value)
                    print("JSON: \(respuestaCodeVerification)")
                    if respuestaCodeVerification["ok"].boolValue {
                        NSNotificationCenter.defaultCenter().postNotificationName("SMSRespond", object: nil)
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName("SMSCodeError", object: nil)
                    }

                }
            case .Failure(let error):
                print(error)
            }
    }
}