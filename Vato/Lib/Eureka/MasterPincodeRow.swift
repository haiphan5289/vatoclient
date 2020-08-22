//  File name   : MasterPincodeRow.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Eureka

public final class MasterPincodeRow: MasterFieldRow<MasterPincodeCell>, RowType {
    public var onFinished: ((Bool) -> Void)?
    public var length = 6

    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
