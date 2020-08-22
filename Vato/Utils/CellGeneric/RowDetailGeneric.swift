//  File name   : RowDetailGeneric.swift
//
//  Author      : Dung Vu
//  Created date: 3/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Eureka

// MARK: - Generic detail
final class RowDetailGeneric<C>: Row<C>, RowType where C: BaseCell, C: CellType, C: UpdateDisplayProtocol {
    override var value: C.Value? {
        didSet {
            cell.setupDisplay(item: value)
        }
    }
    
    func set(callback: SelectCallback?) {
        guard let c = cell as? CallbackSelectProtocol else { return }
        c.set(callback: callback)
    }
    
//    func onChange(_ callback: @escaping (RowDetailGeneric<C>) -> Void) -> RowDetailGeneric<C> {
//        callback(self)
//        return self
//    }
   
}
