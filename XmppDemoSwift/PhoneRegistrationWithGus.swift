//
//  PhoneRegistrationWithGus.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 19/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class PhoneRegistrationWithGus: UIViewController, UITextFieldDelegate, UIScrollViewDelegate{ //Dismissable {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cellPhoneField: UITextField!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var sendPhoneButton: UIButton!
    @IBOutlet weak var miscTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var cellPhoneErrorMessageLabel: UILabel!
    @IBOutlet weak var vistaPhone: UIView!
    
    
    @IBOutlet weak var vistaCode: UIView!
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var textCode: UITextField!
    @IBOutlet weak var volverAEnviarCode: UIButton!
    
    @IBOutlet weak var smsCodeErrorMessage: UILabel!
    @IBOutlet weak var sendSMSCode: UIButton!
    
    var backGroundViewMessagesFrame: CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
   // weak var dismissalDelegate: DismissalDelegate?
    var posVistaPrincipal: CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    var newPos: CGFloat = 0.0
    let limitPhoneNumber = 10
    let limitSMSCode = 4

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellPhoneField.tag = 1
        textCode.tag = 2
        setupDelegates()
        self.hideKeyboardWhenTappedAround()



    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        backGroundViewMessagesFrame = scrollView.frame
        posVistaPrincipal = vistaPhone.frame
        newPos = self.view.frame.size.width + 80
        vistaCode.frame.origin.x += newPos

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func sendPhoneButtonAction(sender: UIButton!) {
        sendNumber(cellPhoneField.text!)
        //mensajeValidoPhone()
    }
    
    @IBAction func sendSMSCodeAction(sender: AnyObject) {
        sendCode(textCode.text!)
    }
    
    //NOTIFICACIONES TECLADO
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendData), name:"sendPhone", object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendData), name:"sendCode", object: nil)
        notificationCenter.addObserver(self, selector: #selector(cerrarSMSWindow), name:"SMSRespond", object: nil)
        notificationCenter.addObserver(self, selector: #selector(mensajeSMSCodeError), name: "SMSCodeError", object: nil)
        notificationCenter.addObserver(self, selector: #selector(mensajeErrorPhone), name:"PhoneError", object: nil)
        notificationCenter.addObserver(self, selector: #selector(mensajeValidoPhone), name: "PhoneValid", object: nil)
        notificationCenter.addObserver(self, selector: #selector(emailValido), name: "EmailValid", object: nil)
        notificationCenter.addObserver(self, selector: #selector(emailError), name: "EmailError", object: nil)



    }
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -(keyboardViewEndFrame.height + 5), right: 0)


        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 5, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        //let selectedRange = cellPhoneField.selectedRange
        //cellPhoneField.scrollRangeToVisible(selectedRange)
    }
    
    //TEXTFIELD DELEGATE
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendPhoneButtonAction(nil)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if newLength == 10 && textField.tag == 1{
            NSNotificationCenter.defaultCenter().postNotificationName("sendPhone", object: nil)
        }else if newLength == 4 && textField.tag == 2{
            NSNotificationCenter.defaultCenter().postNotificationName("sendCode", object: nil)

        }

        return  textField.tag == 1 ? (newLength <= limitPhoneNumber) : (newLength <= limitSMSCode)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1{
            sendPhoneButton.hidden = false
        }
    }
    
    
    
    func setupDelegates(){
        cellPhoneField.delegate = self
        textCode.delegate = self
        scrollView.delegate = self

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //_ = segue.destinationViewController as? ChatViewController
        //let indexPath = self.tableView.indexPathForSelectedRow()
        //viewController.pinCode = self.exams[indexPath.row]
        
        //let navVc = segue.destinationViewController as! UINavigationController // 1
//        if segue.identifier == "toSMSWindow" {
//            _ = segue.destinationViewController as? CodeFromSMSViewController  // 2
//        }
    }
    
    
    //SEND PHONE NUMBER
    
   
    func moverVistaPhone(){
        sendPhoneButton.hidden = true
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {
            self.vistaPhone.frame.origin.x -= self.newPos
            self.vistaPhone.hidden = true
            self.sendPhoneButton.hidden = true
            }, completion: { finished in
               self.moverVistaSMS()
        })
    }
    
    func moverVistaSMS(){
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {
            self.vistaCode.hidden = false
            self.vistaCode.frame = self.posVistaPrincipal
            
            }, completion: {finished in
               print("vistas se movieron")
        })
    
    }
    
    func moverVistaPhoneDeSMS(){
        sendSMSCode.hidden = true

        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {
            self.vistaPhone.hidden = false
            self.cellPhoneField.text = ""
            self.vistaPhone.frame = self.posVistaPrincipal
            }, completion: { finished in
                print("vistas se movieron")
        })
    }
    
    func moverVistaSMSDePhone(){
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {
            self.vistaCode.hidden = true
            self.vistaCode.frame.origin.x += self.newPos
            
            }, completion: {finished in
                self.moverVistaPhoneDeSMS()
        })
        
    }

    @IBAction func reEnviarCodigo(sender: AnyObject) {
        let alertController = UIAlertController(title: "Re-Enviar Código", message: "Selecciona la forma", preferredStyle: .ActionSheet)
        let sms = UIAlertAction(title: "Recibir por SMS", style: .Default, handler: { (action) -> Void in
            self.textCode.resignFirstResponder()
            self.moverVistaSMSDePhone()
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
            print("Cancelar")
        })
        let email = UIAlertAction(title: "Recibir por e-mail", style: .Default) { (action) -> Void in
            self.textCode.resignFirstResponder()
            self.enviarACorreo()
        }
        
        alertController.addAction(sms)
        alertController.addAction(cancelar)
        alertController.addAction(email)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    func enviarACorreo(){
        weak var emailTextField: UITextField?
        let alertController = UIAlertController(title: "Enviar a mi correo", message: nil, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Enviar", style: .Default, handler: { (action) -> Void in
            self.enviarPorEmail((emailTextField?.text)!)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            // Enter the textfiled customization code here.
            emailTextField = textField
            emailTextField?.placeholder = "Correo"
        }
        presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    func enviarPorEmail(email: String){
        sendCodeByEmail(email)
    }
    
    func sendData(){
        if cellPhoneField.isFirstResponder(){
            sendPhoneButton.hidden = false
        }else if textCode.isFirstResponder(){
             sendSMSCode.hidden = false
        }
        
    }
    
    func dismissObservers(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cerrarSMSWindow(){
        smsCodeErrorMessage.text = ""
        textCode.resignFirstResponder()
        dismissObservers()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mensajeErrorPhone(){
        cellPhoneErrorMessageLabel.text = "Ups! Verifica que tu número esta correcto."
       shake(cellPhoneField)
    
    }
    
    func mensajeValidoPhone(){
        cellPhoneErrorMessageLabel.text = ""
        cellPhoneField.resignFirstResponder()
        moverVistaPhone()
    }
    
    func mensajeSMSCodeError(){
        smsCodeErrorMessage.text = "Ups! Verifica que tu número esta correcto."
        shake(textCode)
    
    }
    
    func emailValido(){
    
    
    }
    
    func emailError(){
    
    
    }

}