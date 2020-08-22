//
//  PickerDateTimeVC.swift
//  Vato
//
//  Created by an.nguyen on 8/21/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FSCalendar

class PickerDateTimeVC: UIViewController {

    private lazy var disposeBag = DisposeBag()
    weak var listener: PickerTimeViewControllerListener?
    var currentModel: DateTime!
    var defaultModel: DateTime?
    
    @IBOutlet weak var pickerDate: FSCalendar!
    @IBOutlet weak var pickerTime: UIDatePicker!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        visualize()
    }
    
    private func visualize() {
        currentModel = self.defaultModel ?? DateTime.defautValue(interval: 0)

        self.btnBack.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        self.btnConfirm?.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.listener?.selectTime(model: wSelf.currentModel)
            wSelf.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        pickerTime.rx.date.skip(1).bind(onNext: { [weak self] (d) in
            self?.currentModel.time = d
        }).disposed(by: disposeBag)
        
        pickerDate.delegate = self
        pickerDate.dataSource = self
        pickerDate.select(self.currentModel.date)

        pickerTime.setDate(self.currentModel.time, animated: false)
        pickerTime?.minimumDate = self.currentModel?.date
    }
}

extension PickerDateTimeVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.currentModel.date = date
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}
