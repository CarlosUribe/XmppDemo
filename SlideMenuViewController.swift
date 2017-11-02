//
//  SlideMenuViewController.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 30/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import Foundation
import UIKit

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var menuOptions:[Int:UIImage] = [:]
    var menuTitles:[Int:String] = [:]
    @IBOutlet weak var nombreUsuario: UILabel!
    @IBOutlet weak var btnAjustes: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        menuOptions = [
            0: UIImage(named: "pago")!,
            1: UIImage(named: "direcciones")!,
            2: UIImage(named: "invita")!,
            3: UIImage(named: "promociones")!,
            4: UIImage(named: "historial")!,
            5: UIImage(named: "notificaciones")!,
            6: UIImage(named: "ayuda")!
        ]
        menuTitles = [
            0: "Pago",
            1: "Mis direcciones",
            2: "Invita a tus amigos",
            3: "Promociones",
            4: "Historial de pedidos",
            5: "Notificaciones",
            6: "Ayuda"
        ]

        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let celda =
            tableView.dequeueReusableCellWithIdentifier("CeldaElementosMenu", forIndexPath: indexPath) as! CeldaElementosMenu
        
            celda.imagenTituloMenu.image = menuOptions[indexPath.row]
            celda.imagenTituloMenu.contentMode = .ScaleAspectFit
            celda.labelTitulo.text = menuTitles[indexPath.row]
        
        
        return celda
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
        
    }
    @IBAction func btnAjustesAction(sender: AnyObject) {
        
        
    }

}
