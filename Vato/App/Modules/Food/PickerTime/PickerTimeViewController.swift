//
//  PickerTimeViewController.swift
//  Vato
//
//  Created by vato. on 12/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FSCalendar
import FwiCore

protocol PickerTimeViewControllerListener: class {
    func selectTime(model: DateTime?)
}

class PickerTimeViewController: UIViewController {
    
    var controllerDetail: PickerTimeDetailVC? {
        return children.compactMap { $0 as? PickerTimeDetailVC }.lazy.first
    }
    
    var defaultModel: DateTime?
    
    @IBOutlet private weak var backBtn: UIButton?
    @IBOutlet private weak var timeLbl: UILabel?
    @IBOutlet private weak var confirmBtn: UIButton?
    @IBOutlet private weak var lblSchedulePickup: UILabel?
    
    private lazy var disposeBag = DisposeBag()
    var interval: TimeInterval = DateTime.Config.timeAppendDelivery
    
    weak var listener: PickerTimeViewControllerListener?
    private var currentModel: DateTime!
    
    private func makeDefault() -> DateTime {
        return DateTime.defautValue(interval: interval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        
        // set defaut display data
        self.currentModel = self.defaultModel ?? makeDefault()
        controllerDetail?.pickerTime?.minimumDate = self.currentModel?.date
        
        setupRX()
    }
    
    private func visualize() {
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        controllerDetail?.useValue = defaultModel != nil
        timeLbl?.text = FwiLocale.localized("Hẹn giờ")
    }
    
    private func updateDisplay(_ show: Bool) {
        guard show else {
            return
        }
        
        self.controllerDetail?.pickerTime.setDate(self.currentModel.time, animated: false)
        self.controllerDetail?.pickerDate.select(self.currentModel.date)
    }
    
    private func setupRX() {
        controllerDetail?.changed.bind(onNext: weakify({ (show, wSelf) in
            wSelf.updateDisplay(show)
        })).disposed(by: disposeBag)
        
        self.backBtn?.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.confirmBtn?.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            if wSelf.controllerDetail?.useValue == true {
                wSelf.listener?.selectTime(model: wSelf.currentModel)
            } else {
                wSelf.listener?.selectTime(model: nil)
            }
            wSelf.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.controllerDetail?.pickerTime.rx.date.skip(1).bind(onNext: { [weak self] (d) in
            self?.currentModel.time = d
        }).disposed(by: disposeBag)
        
        self.controllerDetail?.pickerDate.delegate = self
        self.controllerDetail?.pickerDate.dataSource = self
    }
}

extension PickerTimeViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.currentModel.date = date
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
}
