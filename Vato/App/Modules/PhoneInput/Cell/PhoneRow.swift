//  File name   : PhoneRow.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

final class PhoneRow: MasterFieldRow<PhoneCell>, RowType {
    override var value: String? {
        get {
            return super.value
        }
        
        set {
            super.value = newValue
            callBackText?(newValue ?? "")
        }
    }
    
    var callBackText: ((String) -> Void)?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        validationOptions = .validatesOnChange
        onRowValidationChanged(validationChangedClosure)
    }
    
}
