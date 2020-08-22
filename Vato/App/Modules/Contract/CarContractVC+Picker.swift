//
//  BookContractVC+Picker.swift
//  Vato
//
//  Created by an.nguyen on 8/18/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import FSCalendar
import Eureka

extension CarContractVC {
    func createPicker() -> UIPickerView {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 180))
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
//        if let sizePackageSelect = self.listener?.newInfo.packageSize,
//            let index = self.sizePackages.firstIndex(where: { $0.id == sizePackageSelect.id }) {
//            self.picker.selectRow(index, inComponent: 0, animated: false)
//        }
        
        return picker
    }
    
    func createToolBar() {
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: Text.done.localizedText, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        doneButton.tintColor = Color.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }
    
    @objc func donePicker() {
        if let tf = self.tableView.findFirstResponder() as? UITextField {
            tf.resignFirstResponder()
        }
    }
    
    func createPickerDate() {
        pickerDate = FSCalendar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250))
        pickerDate.backgroundColor = .white

        pickerDate.dataSource = self
        pickerDate.delegate = self
    }
    
//    func getCurrentRow() -> RowInputDelivery<DropBoxCell>? {
//        var crtRowTag = ""
//        if let tf = self.tableView.findFirstResponder(){
//            let tagTf = tf.tag
//            crtRowTag = FillContractCellType.allCases[tagTf-1].rawValue
//        }
//        let crrRow  = self.form.rowBy(tag: crtRowTag)
//        if let crr = crrRow as? RowInputDelivery<DropBoxCell> {
//            return crr
//        }
//        return nil
//    }
    
    func getCurrentSource(picker: UIPickerView) -> [String] {
        var sources: [String] = []
        if picker === picker1 {
            sources = source1 ?? []
        } else if ( picker === picker2 ) {
            sources = source2 ?? []
        }
        else if ( picker === picker3 ) {
            sources = source3 ?? []
        }
        return sources
    }
}

extension CarContractVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let sources = getCurrentSource(picker: pickerView)
        return sources.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let sources = getCurrentSource(picker: pickerView)
        return sources[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sources = getCurrentSource(picker: pickerView)
        if let tf = self.tableView.findFirstResponder() as? UITextField {
            tf.text = sources[safe: row]
            tf.sendActions(for: .valueChanged)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension CarContractVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        self.listener?.didSelectDate(date: date)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}

//            self.update(type: .sizePackage, value: model.name)
//            self.listener?.newInfo.packageSize = model
