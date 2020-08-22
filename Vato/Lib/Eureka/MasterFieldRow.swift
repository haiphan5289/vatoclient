//  File name   : MasterFieldRow.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 9/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

public typealias ValidationChanged = (BaseRow) -> Void
public protocol MasterFieldRowProtocol {
    var titleFont: UIFont { get }
    var detailFont: UIFont { get }

    var titleColor: UIColor { get }
    var detailColor: UIColor { get }
    var disabledTitleColor: UIColor { get }
    var disabledDetailColor: UIColor { get }

    var validationChanged: ValidationChanged? { get set }
}

open class MasterFieldRow<Cell>: FieldRow<Cell>, MasterFieldRowProtocol where Cell : BaseCell, Cell: CellType, Cell: TextFieldCell {
    /// Class's public properties.
    open var titleFont: UIFont
    open var detailFont: UIFont

    open var titleColor: UIColor
    open var detailColor: UIColor
    open var disabledTitleColor: UIColor
    open var disabledDetailColor: UIColor

    public var validationChanged: ValidationChanged?

    /// Class's constructors
    public required init(tag: String?) {
        titleFont = EurekaConfig.titleFont
        detailFont = EurekaConfig.detailFont

        titleColor = EurekaConfig.titleColor
        detailColor = EurekaConfig.detailColor
        disabledTitleColor = EurekaConfig.disabledTitleColor
        disabledDetailColor = EurekaConfig.disabledDetailColor
        
        super.init(tag: tag)
        placeholderColor = EurekaConfig.placeholderColor
        validationOptions = .validatesOnBlur
    }
    
    /// Class's private properties
    internal let validationChangedClosure: (Cell, BaseRow) -> Void = { (cell, row) -> Void in
        // Display error message if row is invalid, only display the first one
        guard
            let masterCell = cell as? MasterFieldCellProtocol,
            let masterRow = row as? MasterFieldRowProtocol
        else {
            return
        }

        if !row.isValid, let validationMessage = row.validationErrors.first?.msg {
            masterCell.titleLabel.textColor = EurekaConfig.errorColor
            masterCell.titleLabel.text = validationMessage
        } else {
            masterCell.titleLabel.textColor = masterRow.titleColor
            masterCell.titleLabel.text = row.title
        }

        masterRow.validationChanged?(row)
    }
}

public final class MasterAccountFieldRow: MasterFieldRow<MasterAccountFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterEmailFieldRow: MasterFieldRow<MasterEmailFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterNameFieldRow: MasterFieldRow<MasterNameFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterPasswordFieldRow: MasterFieldRow<MasterPasswordFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterPhoneFieldRow: MasterFieldRow<MasterPhoneFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterTextFieldRow: MasterFieldRow<MasterTextFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterURLFieldRow: MasterFieldRow<MasterURLFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterZipCodeFieldRow: MasterFieldRow<MasterZipCodeFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}

public final class MasterIntFieldRow: MasterFieldRow<MasterIntFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        
        formatter = numberFormatter
        useFormatterDuringInput = true
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterDecimalFieldRow: MasterFieldRow<MasterDecimalFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        
        formatter = numberFormatter
        useFormatterDuringInput = true
        onRowValidationChanged(validationChangedClosure)
    }
}
