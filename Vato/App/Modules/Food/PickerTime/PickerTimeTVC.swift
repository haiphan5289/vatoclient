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

final class PickerTimeBaseTVC {
    
}

final class PickerTimeDetailVC: UITableViewController {
    @IBOutlet weak var pickerTime: UIDatePicker!
    @IBOutlet weak var pickerDate: FSCalendar!
    
    @IBOutlet weak var switchMode: UISwitch?
    @IBOutlet weak var lblAsap: UILabel!
    private lazy var disposeBag = DisposeBag()
    @VariableReplay var useValue: Bool = false
    
    var changed: Observable<Bool> {
        return $useValue.distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        lblAsap.text = Text.asSoonAsPossible.localizedText
        setupRX()
    }
    
    private func updateSwith(_ mode: Bool) {
        guard self.switchMode?.isOn == !mode else { return }
        self.switchMode.setOn(mode, animated: false)
    }
    
    private func setupRX() {
        switchMode?.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            let current = wSelf.useValue
            wSelf.useValue = !current
        })).disposed(by: disposeBag)
        
        changed.bind(onNext: weakify({ (use, wSelf) in
            wSelf.updateSwith(!use)
            guard use else {
                return wSelf.tableView.reloadSections([1, 2], with: .fade)
            }
            wSelf.tableView.reloadData()
        })).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 40
        case 1, 2:
            guard useValue else {
                return 0
            }
            return UITableView.automaticDimension
        default:
            fatalError("Please Implement")
            
        }
    }
}
