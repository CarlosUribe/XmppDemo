//
//  CellAccionable_Cotizaciones.swift
//  XmppDemoSwift
//
//  Created by Carlos Uribe on 03/05/16.
//  Copyright © 2016 HolaGus. All rights reserved.
//

import Foundation
import UIKit
class CellAccionable_Cotizaciones: UITableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        
        set {
            collectionView.contentOffset.x = newValue
        }
    }
    func setCollectionViewDataSourceDelegate <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}