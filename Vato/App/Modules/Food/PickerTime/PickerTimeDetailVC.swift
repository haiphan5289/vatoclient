//
//  PickerTimeTVC.swift
//  Vato
//
//  Created by vato. on 12/12/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import FwiCore

final class PickerTimeBaseTVC: UITableViewCell {
    @IBOutlet var iconView: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        iconView?.isHighlighted = selected
        let colorText: UIColor = !selected ? #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1) : #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        let font: UIFont = !selected ? .systemFont(ofSize: 18, weight: .regular) : .systemFont(ofSize: 18, weight: .medium)
        lblTitle?.textColor = colorText
        lblTitle?.font = font
    }
}

final class PickerTimeDetailVC: UITableViewController {
    @IBOutlet weak var pickerTime: UIDatePicker!
    @IBOutlet weak var pickerDate: FSCalendar!
    
    @IBOutlet weak var switchMode: UISwitch?
    @IBOutlet weak var lblTime1: UILabel?
    @IBOutlet weak var lblTime2: UILabel?
    
    @IBOutlet weak var lblDate1: UILabel?
    @IBOutlet weak var lblDate2: UILabel?
    
    private lazy var disposeBag = DisposeBag()
    @VariableReplay var useValue: Bool = false
    
    var changed: Observable<Bool> {
        return $useValue.distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        pickerDate?.appearance.caseOptions = .headerUsesUpperCase
        pickerDate?.appearance.headerTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        pickerDate?.appearance.headerDateFormat = "MMMM/yyyy"
        lblTime1?.text = FwiLocale.localized("Giao ngay")
        lblTime2?.text = FwiLocale.localized("Hẹn giờ tự do")
        lblDate1?.text = FwiLocale.localized("Chọn ngày")
        lblDate2?.text = FwiLocale.localized("Chọn giờ")
        setupRX()
    }
    
    private func updateSwith(_ mode: Bool) {
        guard self.switchMode?.isOn == !mode else { return }
        self.switchMode?.setOn(mode, animated: false)
    }
    
    private func setupRX() {
        switchMode?.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            let current = wSelf.useValue
            wSelf.useValue = !current
        })).disposed(by: disposeBag)
        
        changed.bind(onNext: weakify({ (use, wSelf) in
            wSelf.updateSwith(!use)
            wSelf.tableView.reloadData()
            let idx: IndexPath = IndexPath(item: use ? 1 : 0, section: 0)
            DispatchQueue.main.async {
                wSelf.tableView.selectRow(at: idx, animated: false, scrollPosition: .none)
            }
        })).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 56
            case 1:
                guard useValue else {
                    return 56
                }
                return UITableView.automaticDimension
            default:
                fatalError("Please Implement")
            }
        default:
            fatalError("Please Implement")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        useValue = indexPath.row == 1
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
