//
//  ChatTableViewController.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 03/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import UIKit
import XMPPFramework


class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, ChatDelegate, OneMessageDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, BubbleButtonActionsProtocol, OneRosterDelegate{ //DismissalDelegate{
    
    let model: [[UIColor]] = generateRandomData()
    //TIPOS DE MENSAJE
    
    enum TiposMensaje:Int {
        case MensajeGus = 1, MensajeUsuario, MensajeGenericoTextoBoton, MensajeProductoImgDetallePrecioBoton, MensajeConversacionesActivas
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    var messages = NSMutableArray()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var onlineBuddies = NSMutableArray()
    let mensajesRecividos = MESSAGE_RECIVED
    let appDelegate2 = UIApplication.sharedApplication().delegate as! AppDelegate
    var recipient: XMPPUserCoreDataStorageObject?
    var images: UIImage!
    //TOMAR FOTOS
    var imagePicker: UIImagePickerController!
    var isMediaMessage: Bool!
    //var userIsTypingRef: Firebase!
    //var usersTypingQuery: FQuery!
    private var localTyping = false
    var botVerticalChatUser: String!
    
    var storedOffsets = [Int: CGFloat]()
   
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageField: UITextView!
    //BUBBLE
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: BubbleDataType?
    var rowCellSize: CGFloat = 0.0
    //TEXT
    @IBOutlet weak var constrainTopView2TableView: NSLayoutConstraint!
    
    @IBOutlet weak var constrainBottomView2ScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var backGroundViewMessages: UIView!
    
    @IBOutlet weak var constrainTableView2TopScrollView: NSLayoutConstraint!
    @IBOutlet weak var canstrainMessageView2View: NSLayoutConstraint!
    var backGroundViewMessagesFrame: CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    var previousRect = CGRectZero
    var prueba: Bool = false
    var saltoDeLineaPrueba: Bool = false
   
    //VARIABLES PARA CONECTAR AL XMPP Y CONECTAR CON UN USUARIO DIRECTAMENTE 
    //USER ID´s
    let user: String = "user@localhost"
    let pass: String = "user"
    var delegate:ContactPickerDelegate?

    //CONSTRAINS DE TABLEVIEW
    
    @IBOutlet weak var constrainTableViewChat: NSLayoutConstraint!
    
    //BARRA DE NAVEGACION
    
    @IBOutlet weak var menuNavButton: UIBarButtonItem!
    
    @IBOutlet weak var chatsNavButton: UIBarButtonItem!
    
    //VARIABLES A BORRAR
    var tipoMensaje: Int = 0
    
       override func viewDidLoad() {
        super.viewDidLoad()
        //messageRef = rootRef.childByAppendingPath("messages")
        //NOTIFICACIONES TECLADO
        //registerForKeyboardNotifications()
      
        //Configurar barra de estado dependiendo de la vertical donde se encuentre el usario
        if OneChat.sharedInstance.isConnected() {
            //self.senderId = OneChat.sharedInstance.xmppStream?.myJID.bare()
            //self.senderDisplayName = OneChat.sharedInstance.xmppStream?.myJID.bare()
        }
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.appendMessage), name: mensajesRecividos, object: nil)
        isMediaMessage = false
        
        self.messagesTableView.estimatedRowHeight = 200
        self.messagesTableView.rowHeight = UITableViewAutomaticDimension
        let amountOfLinesToBeShown:CGFloat = 6
        let maxHeight:CGFloat = messageField.font!.lineHeight * amountOfLinesToBeShown
        messageField.sizeThatFits(CGSizeMake(messageField.frame.size.width, maxHeight))
        
        let scrollSize = CGSizeMake(self.view.frame.size.height, 1.0)
        scrollView.contentSize = scrollSize
        self.hideKeyboardWhenTappedAround()
        setNavBar()
        setupDelegates()
        setMessagesTableView()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let pos = messageField.endOfDocument
        previousRect = messageField.caretRectForPosition(pos)
        backGroundViewMessagesFrame = scrollView.frame
        loginAutomatico()

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setBackGroundImage4TableView()
        registerForKeyboardNotifications()


    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    

    func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?

        let mensajes: MessageObject = messages.objectAtIndex(indexPath.row) as! MessageObject

        switch mensajes.tipoMensaje {
        case TiposMensaje.MensajeGus.rawValue:
            let celda =
                tableView.dequeueReusableCellWithIdentifier("CeldaMensajesGus", forIndexPath: indexPath) as! CeldaMensajesGus
            let chatBubbleData = ChatBubbleData(text: mensajes.text, image:nil, date: NSDate(),
                                                button: [], tituloBoton: [], tipoAccionBoton: nil,
                                                type: .GUS)
            //let padding:CGFloat = lastMessageType == chatBubbleData.type ? internalPadding/3.0 :  internalPadding
            let chatBubble = ChatBubble(data: chatBubbleData, startY:5.0)
            chatBubble.frame.origin.x =  self.view.frame.origin.x + 10
            chatBubble.frame.origin.y = 5.0
            rowCellSize = chatBubble.frame.size.height + 30.0
            
            celda.vistaMensajeGus.addSubview(chatBubble)
            
            //celda.mensajeGus.text = mensajes.text
            //celda.mensajeGus.adjustsFontSizeToFitWidth = true
            
            return celda

        case TiposMensaje.MensajeUsuario.rawValue:
            let celda =
                tableView.dequeueReusableCellWithIdentifier("CeldaMensajesUsuario", forIndexPath: indexPath) as! CeldaMensajesUsuarios
            
            let chatBubbleData = ChatBubbleData(text: mensajes.text, image:nil, date: NSDate(),
                                                button: [], tituloBoton: [], tipoAccionBoton: nil,
                                                type: .USER)
            //let padding:CGFloat = lastMessageType == chatBubbleData.type ? internalPadding/3.0 :  internalPadding
            let chatBubble = ChatBubble(data: chatBubbleData, startY:5.0)
            chatBubble.frame.origin.x = self.view.frame.size.width - 85
            chatBubble.frame.origin.y = 19.0
            rowCellSize = chatBubble.frame.size.height + 40.0
            
            celda.vistaMensajeUsuario.addSubview(chatBubble)
            
            return celda
        case TiposMensaje.MensajeGenericoTextoBoton.rawValue:
            let celda =
                tableView.dequeueReusableCellWithIdentifier("CeldaMensajesGus", forIndexPath: indexPath) as! CeldaMensajesGus
            var button: [UIButton] = []
            var titulo: [String] = []
            let buttonAction: UIButton? = UIButton(frame: CGRectMake(0, 0, 50, 30))
                buttonAction?.titleLabel?.font.fontWithSize(12.0)
           // let tipoAccionBoton = 1
            let tituloBoton = "Ingresa Móvil"
            button.append(buttonAction!)
            titulo.append(tituloBoton)
            
            //EL TITULO SE OBTIENE DEL MENSAJE
            //LA ACCIÓN TAMBIEN SE OBTIENE DEL MENSAJE
            let chatBubbleData = ChatBubbleData(text: mensajes.text, image:nil, date: NSDate(),
                                                button: button, tituloBoton: titulo, tipoAccionBoton: 1,
                                                type: .ACTION)
            let chatBubble = ChatBubble(data: chatBubbleData, startY:5.0)
            chatBubble.delegate = self
            chatBubble.frame.origin.x = 8.0
            chatBubble.frame.origin.y = 5.0
            rowCellSize = chatBubble.frame.size.height + 30.0
            celda.constrainHeigth.constant = chatBubble.frame.size.height + 30.0

                        //celda.botonGenericoView.titleLabel = ""
            //celda.botonGenericoView.backgroundImageForState(<#T##state: UIControlState##UIControlState#>)
            
            //celda.textoGenericoView.text = ""
            
            celda.vistaMensajeGus.addSubview(chatBubble)

            return celda
            
        case TiposMensaje.MensajeProductoImgDetallePrecioBoton.rawValue:
            let celda =
                tableView.dequeueReusableCellWithIdentifier("CeldaMensajesGus", forIndexPath: indexPath) as! CeldaMensajesGus
            
            ///CHECAR DEL MENSAJE RECIBIDO EL ARREGLO DE BOTONES QUE MANDA Y CON  ESA ETRUCTURA CREAR LOS BOTONES
            let botones:[Int] = [1,2]
            var button: [UIButton] = []
            var titulo: [String] = []
            //EN VEZ DE "_" VA "BOTONES"
            for _ in botones{
                //EL BOTON SE CREA EN EL MOMENTO PERO EL TITULO SE OBTIENE DEL JSON QUE SE MANDA EN EL MENSAJE
                //EJ; EL ELEMENTO "BOTONES" CONTIENE EL TITULO, ESE ES EL VALOR QUE SE LE DA A LA VARIABLE "tituloBoton"
                let buttonAction: UIButton? = UIButton(frame: CGRectMake(0, 0, 50, 30))
                buttonAction?.titleLabel?.font.fontWithSize(12.0)
                let tituloBoton = "Ingresa Móvil"
                button.append(buttonAction!)
                titulo.append(tituloBoton)
                botones
            }
            if mensajes.urlImage != "" {
                let chatBubbleData = ChatBubbleData(text: mensajes.text, image:nil, date: NSDate(),
                                                    button: button, tituloBoton: titulo, tipoAccionBoton: 1,
                                                    type: .ACTION)
                let chatBubble = ChatBubble(data: chatBubbleData, startY:5.0)
                chatBubble.delegate = self
                chatBubble.frame.origin.x = 8.0
                chatBubble.frame.origin.y = 5.0
                rowCellSize = chatBubble.frame.size.height + 30.0
                celda.constrainHeigth.constant = chatBubble.frame.size.height + 30.0
                celda.vistaMensajeGus.addSubview(chatBubble)

                
            }else{
                let chatBubbleData = ChatBubbleData(text: mensajes.text, image:nil, date: NSDate(),
                                                    button: button, tituloBoton: titulo, tipoAccionBoton: 1,
                                                    type: .ACTION)
                let chatBubble = ChatBubble(data: chatBubbleData, startY:5.0)
                chatBubble.delegate = self
                chatBubble.frame.origin.x = 8.0
                chatBubble.frame.origin.y = 5.0
                rowCellSize = chatBubble.frame.size.height + 30.0
                celda.constrainHeigth.constant = chatBubble.frame.size.height + 30.0
                
                
                celda.vistaMensajeGus.addSubview(chatBubble)

            
            }
            
            return celda
            
        case TiposMensaje.MensajeConversacionesActivas.rawValue:
            let celda =
                tableView.dequeueReusableCellWithIdentifier("CeldaConversacionesActivas", forIndexPath: indexPath) as! CeldaConversacionesActivas
            
            
            return celda
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("CellAccionable_Cotizaciones",forIndexPath: indexPath)
            print("Error")
        }
        
        return cell!

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return rowCellSize
    }
    
    func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? CellAccionable_Cotizaciones else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(tableView: UITableView,
                            didEndDisplayingCell cell: UITableViewCell,
                                                 forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? CellAccionable_Cotizaciones else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return model[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell_Cotizacion",
                                                                         forIndexPath: indexPath)
        
        cell.backgroundColor = model[collectionView.tag][indexPath.item]
        
        return cell
    }

    ////CHATDELEGATE's
    func buddyWentOnline(name: String) {
        if !onlineBuddies.containsObject(name) {
            onlineBuddies.addObject(name)
        }
    }
    
    func buddyWentOffline(name: String) {
        onlineBuddies.removeObject(name)
    }
    
    func didDisconnect() {
        onlineBuddies.removeAllObjects()
    }
    
    //    func appendMessage(){
    //        let mensaje = self.appDelegate2.mensaje
    //
    //        let message = JSQMessage(senderId: "1", displayName: "", text: mensaje)
    //        messages.append(message)
    //    }
    //
    //ONE_MESSAGES_DELEGATE
    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {
        if message.isChatMessageWithBody() {
            //JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            tipoMensaje = 3
            if let msg: String = message.elementForName("body")?.stringValue() {
                if let from: String = message.attributeForName("from")?.stringValue() {
                    let message = MessageObject(senderId: from, senderDisplayName: from, date: NSDate(), isMediaMessage: isMediaMessage, text: msg, urlImage: "no-url", tipoMensaje:tipoMensaje)
                    botVerticalChatUser = from
                    messages.addObject(message)
                    let savedData = NSKeyedArchiver.archivedDataWithRootObject(message)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(savedData, forKey: "message")
                    messagesTableView.reloadData()
                    scrollToLastRow()
                    //self.finishReceivingMessageAnimated(true)
                }
            }
        }
    }
    

    @IBAction func sendButtonPress(sender: UIButton!) {
        messageField.resignFirstResponder()
        constrainTopView2TableView.constant = 0.0
        scrollView.frame = backGroundViewMessagesFrame
        //canstrainMessageView2View.constant = 0.0
        //constrainTableView2TopScrollView.constant = 46.0
        let message = MessageObject(senderId: (OneChat.sharedInstance.xmppStream?.myJID.bare())!, senderDisplayName: (OneChat.sharedInstance.xmppStream?.myJID.bare())!, date: NSDate(), isMediaMessage: isMediaMessage, text: messageField.text!, urlImage: "no-url", tipoMensaje: TiposMensaje.MensajeUsuario.rawValue)
        messages.addObject(message)
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(message)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "message")
        
       // if let recipient = recipient {
            OneMessage.sendMessage(messageField.text!, to: botVerticalChatUser!, completionHandler: {(stream, message) -> Void
                in
                //MANDAR SONIDO DE MENSAJE SALIENTE
                self.messagesTableView.reloadData()
                self.messageField.text = ""
                self.sendButton.hidden = true
                self.scrollToLastRow()
            })
        }

    
    
    func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
        //self.showTypingIndicator = !self.showTypingIndicator
        //self.scrollToBottomAnimated(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        //super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        // isTyping = textView.text != ""

        if textView.text.characters.count > 0{
            sendButton.hidden = false
        }else{
            sendButton.hidden = true
        }
        let pos = textView.endOfDocument
        let currentRect = textView.caretRectForPosition(pos)
        if prueba {
            previousRect = currentRect
            prueba = false
            if saltoDeLineaPrueba{
                constrainTopView2TableView.constant += 18.0
            }
        }
        if textView.text.containsString("\n"){
            saltoDeLineaPrueba = true
        }else{
            saltoDeLineaPrueba = false
        }
        if(currentRect.origin.y < previousRect.origin.y || saltoDeLineaPrueba){
           
            if (currentRect.origin.y < 1 || saltoDeLineaPrueba) {
                constrainTopView2TableView.constant -= 18.0
            }else {
                constrainTopView2TableView.constant += 18.0
            }
            prueba = true
        }
        previousRect = currentRect
        
    }
    
  
    
    //NOTIFICACIONES TECLADO
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func adjustForKeyboard(notification: NSNotification) {
        scrollToLastRow()
        //let userInfo = notification.userInfo!
        
        //let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
//            if messageField.text.characters.count == 0{
//                constrainTopView2TableView.constant = 0
//            }
//            scrollView.contentInset = UIEdgeInsetsZero
//            scrollView.frame = backGroundViewMessagesFrame
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                constrainTopView2TableView.constant += keyboardSize.height
                self.backGroundViewMessages.frame.origin.y += keyboardSize.height

            }
        } else {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.backGroundViewMessages.frame.origin.y -= keyboardSize.height
                constrainTopView2TableView.constant -= keyboardSize.height
            }
            
        }
        
        
    
       // scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        //let selectedRange = messageField.selectedRange
        //messageField.scrollRangeToVisible(selectedRange)
    }
    
    
    //NAVEGACIÓN
    func setNavBar(){
        //let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 68))
        let navBar = self.navigationController?.navigationBar
        
        let logo = UIImage(named: "logo")
        //let chat = UIImage(named: "chats")
        //let menu = UIImage(named: "menu")
        
        let logoView = UIImageView(image:logo)
        //let navItem = UINavigationItem(title: "Gus");
        
        //menuNavButton.setBackgroundImage(menu, forState: .Normal, barMetrics: .Default)
        //chatsNavButton.setBackgroundImage(chat, forState: .Normal, barMetrics: .Default)
        
        
        self.navigationItem.titleView = logoView
        self.navigationItem.rightBarButtonItem = chatsNavButton
        self.navigationItem.leftBarButtonItem = menuNavButton
        
       
        
        if self.revealViewController() != nil {
            menuNavButton.target = self.revealViewController()
            menuNavButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        navBar!.translucent = true
        navBar?.barTintColor = UIColor.whiteColor()
        
        //let navItem = UINavigationItem(title: "Gus");
       

    }
    
    //MISC.
    
    func setBackGroundImage4TableView(){
        let backgroundImage = UIImage(named: "chatbg")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .ScaleAspectFill 
        self.messagesTableView.backgroundView = imageView

    
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0  || scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    //ACCION BOTONES DENTRO DE MENSAJES
    //ACCION TIPO 1
    func accionBotonPideCelular(sender: UIButton){
        //toPhoneWindow
        self.performSegueWithIdentifier("toPhoneWindow", sender: self)
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //_ = segue.destinationViewController as? ChatViewController
        //let indexPath = self.tableView.indexPathForSelectedRow()
        //viewController.pinCode = self.exams[indexPath.row]
        
        //let navVc = segue.destinationViewController as! UINavigationController // 1
        if segue.identifier == "toPhoneWindow" {
            _ = segue.destinationViewController as? PhoneRegistrationWithGus  // 2
        }
//        if let vc = segue.destinationViewController as? Dismissable{
//            vc.dismissalDelegate = self
//        }
    }
 
    
    func setupDelegates(){
        appDelegate.delegate = self
        OneMessage.sharedInstance.delegate = self
        messageField.delegate = self
        scrollView.delegate = self
        OneRoster.sharedInstance.delegate = self

    
    }
    
    func setMessagesTableView(){
      // constrainTableViewChat.constant = self.view.frame.size.width
    
    }

    //ACCIONES BOTONES DE BARRA DE NAVEGACIÓN
    
    func chatActionButton(sender: UIButton!){
        
    
    }
    
    //ACCIONES DE TABLEVIEW
    func scrollToLastRow() {
        if messages.count > 1{
            let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
            self.messagesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)

        }
    }
    
    //CONEXIÓN A XMPP
    
    func loginAutomatico(){
        
        NSUserDefaults.standardUserDefaults().setObject(user, forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject(pass, forKey: "userPassword")
        OneChat.sharedInstance.connect(username: user, password: pass) {
            (stream, error) -> Void in
            if let _ = error {
                let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    self.presentViewController(alertController, animated: true, completion: nil)
                }))
            }else{
                if OneRoster.buddyList.sections!.count > 0 {
                    let tmp = NSIndexPath(forRow: 0, inSection: 0)
                    self.delegate?.didSelectContact(OneRoster.userFromRosterAtIndexPath(indexPath: tmp))
                }
            
            
            }
        }
    }
    
    func oneRosterContentChanged(controller: NSFetchedResultsController) {
    }

    
}