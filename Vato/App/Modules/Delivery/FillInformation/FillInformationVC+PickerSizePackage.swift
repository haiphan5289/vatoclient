//
//  FillInformationVC+PickerSizePackage.swift
//  Vato
//
//  Created by vato. on 11/20/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

struct PackageSize {
    var id: Int?
    var name: String?
    
    static func generateData() -> [PackageSize] {
        return [
            PackageSize(id: 0, name: "< 10 x 10 x 10 cm"),
            PackageSize(id: 1, name: "< 20 x 20 x 20 cm"),
            PackageSize(id: 2, name: "< 30 x 30 x 30 cm"),
            PackageSize(id: 3, name: "< 40 x 40 x 40 cm"),
            PackageSize(id: 4, name: "< 50 x 50 x 50 cm"),
            PackageSize(id: 5, name: "< 60 x 60 x 60 cm"),
        ]
    }
}

extension FillInformationVC {
    func createPicker() {
        picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 180))
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Text.done.localizedText, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        doneButton.tintColor = Color.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        if let sizePackageSelect = self.listener?.newInfo.packageSize,
            let index = self.sizePackages.firstIndex(where: { $0.id == sizePackageSelect.id }) {
            self.picker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    @objc func donePicker() {
        let cell = self.form.rowBy(tag: FillInformationCellType.sizePackage.rawValue)
        if let sizePackage = cell as? RowInputDelivery<FillInformationDropBoxCell> {
            sizePackage.cell.textField.resignFirstResponder()
        }
    }
    
    @objc func cancelPicker() {
        let cell = self.form.rowBy(tag: FillInformationCellType.sizePackage.rawValue)
        if let sizePackage = cell as? RowInputDelivery<FillInformationDropBoxCell> {
            sizePackage.cell.textField.resignFirstResponder()
        }
    }
}

extension FillInformationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizePackages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizePackages[safe: row]?.name ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let model = self.sizePackages[safe: row] {
            self.update(type: .sizePackage, value: model.name)
            self.listener?.newInfo.packageSize = model
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
