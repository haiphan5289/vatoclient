//  File name   : EcomStoresListVC.swift
//
//  Author      : Dung Vu
//  Created date: 7/23/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
final class EcomStoresListVC: VatoActionSheetVC<FoodGenericTVC<FoodDiscoveryView>> {
    /// Class's public properties.

    // MARK: View's lifecycle
    
    /// Class's private properties.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? LazyDisplayImageProtocol else { return }
        DispatchQueue.main.async {
            c.displayImage()
        }
    }
    
    override func updateDisplay(index: Int, element: VatoActionSheetVC<FoodGenericTVC<FoodDiscoveryView>>.D, cell: FoodGenericTVC<FoodDiscoveryView>) {
        cell.setupDisplay(item: element)
        cell.view.containerBrand?.isHidden = true
    }
}

