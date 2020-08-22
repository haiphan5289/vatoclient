//
//  DeliveryPickerTimeTVC.swift
//  Vato
//
//  Created by vato. on 12/12/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FSCalendar



protocol DeliveryPickerTimeTVCListener: class {
    func didSelectDate(date: Date)
    func didSelectTime(time: String)
}


class DeliveryPickerTimeTVC: UITableViewController {
    @IBOutlet weak var pickerDate: FSCalendar!
    @IBOutlet weak var timePicker: UIPickerView!
    
    weak var listener: DeliveryPickerTimeTVCListener?
    var arrTime: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        self.pickerDate.dataSource = self
        self.pickerDate.delegate = self
    }
    
    func reloadData(datas: [String]) {
        self.arrTime = datas
        self.timePicker.reloadAllComponents()
        if self.arrTime.count > 0 {
            self.timePicker.selectRow(0, inComponent: 0, animated: false)
            self.listener?.didSelectTime(time: self.arrTime[0])
        }
    }
}

extension DeliveryPickerTimeTVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrTime[safe: row] ?? ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrTime.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let time = self.arrTime[safe: row] else { return }
        self.listener?.didSelectTime(time: time)
    }
}

extension DeliveryPickerTimeTVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.listener?.didSelectDate(date: date)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}
