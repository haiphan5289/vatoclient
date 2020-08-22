//
//  DeliveryPickerTimeViewController.swift
//  Vato
//
//  Created by vato. on 12/31/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift

struct DeliveryTime {
    let dateStr: String
    let arrTime: [String]
}

class DeliveryPickerTimeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var timePicker: UIPickerView?
    @IBOutlet weak var containerView: UIView?
    
    private let source = [DeliveryTime(dateStr: "Hôm nay",
                                       arrTime: [ "06:00 - 09:00", "09:00 - 12:00", "12:00 - 14:00", "14:00 - 15:00", "15:00 - 17:00", "17:00 - 19:00", "19:00 - 20:00", "20:00 - 22:00", "22:00 - 23:00"]),
                          DeliveryTime(dateStr: "Ngày mai",
                                       arrTime: [ "04:00 - 06:00", "06:00 - 09:00", "09:00 - 12:00", "12:00 - 14:00", "14:00 - 15:00", "15:00 - 17:00", "17:00 - 19:00", "19:00 - 20:00", "20:00 - 22:00", "22:00 - 23:00"]),
                          DeliveryTime(dateStr: "08/01/2020",
                                       arrTime: [ "04:00 - 06:00", "04:00 - 06:00", "06:00 - 09:00", "09:00 - 12:00", "12:00 - 14:00", "14:00 - 15:00", "15:00 - 17:00", "17:00 - 19:00", "19:00 - 20:00", "20:00 - 22:00", "22:00 - 23:00"])]
    
    private let dispoBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        timePicker?.delegate = self
        timePicker?.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = .identity
        }
    }
    
    private func setupRX() {
        closeButton?.rx.tap.bind(onNext: { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: dispoBag)
    }
    
    private func visualize() {
        let viewBG = HeaderCornerView(with: 7)
        viewBG.containerColor = .white
        containerView?.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let p = UIPanGestureRecognizer(target: nil, action: nil)
        containerView?.addGestureRecognizer(p)
        containerView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
    }
}

extension DeliveryPickerTimeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return source.count
        } else {
            let idx = pickerView.selectedRow(inComponent: 0)
            return source[safe: idx]?.arrTime.count ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let key = source[safe: row]?.dateStr ?? ""
            return key
        } else {
            let idx = pickerView.selectedRow(inComponent: 0)
            let value = source[safe: idx]?.arrTime[safe: row] ?? ""
            return value
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}
