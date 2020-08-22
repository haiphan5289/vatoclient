//
//  DeliveryPickerTimeViewController.swift
//  Vato
//
//  Created by vato. on 12/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FSCalendar
import VatoNetwork
import FwiCoreRX

protocol DeliveryPickerTimeViewControllerListener: class {
    func selectTime(model: DeliveryDateTime)
}

struct DeliveryDateTime: Equatable {
    private struct Config {
        static let formatDate = "yyyy-MM-dd"
        static let timeAppendDelivery = 30 //minute
    }
    
    var date: Date
    var time: String?
    
    static func defautValue() -> DeliveryDateTime {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: Config.timeAppendDelivery, to: Date()) ?? Date()
        
        return DeliveryDateTime(date: date)
    }
    
    var dateDescription: String { return date.string(from: Config.formatDate) }
    
    func string() -> String { return "\(time ?? "")  \(dateDescription)" }
    
}


class DeliveryPickerTimeViewController: UIViewController, ActivityTrackingProgressProtocol, LoadingAnimateProtocol, DisposableProtocol {
    
    var controllerDetail: DeliveryPickerTimeTVC? {
        return children.compactMap { $0 as? DeliveryPickerTimeTVC }.first
    }
    @IBOutlet private weak var backBtn: UIButton?
    @IBOutlet private weak var timeLbl: UILabel?
    @IBOutlet private weak var confirmBtn: UIButton?
    
    var token: Observable<String>?
    var defaultModel: DeliveryDateTime?
    
    internal lazy var disposeBag = DisposeBag()
    var disposeRequest: Disposable?
    weak var listener: DeliveryPickerTimeViewControllerListener?
    private var currentModel: DeliveryDateTime = DeliveryDateTime.defautValue() {
        didSet { timeLbl?.text = currentModel.string() }
    }
    
    convenience init(token: Observable<String>) {
        self.init()
        self.token = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        
        // set defaut display data
        self.currentModel = self.defaultModel ?? self.currentModel
        self.controllerDetail?.pickerDate.select(self.currentModel.date)
        self.timeLbl?.text = self.currentModel.string()
        setupRX()
        requestTimesAvailable(date: self.currentModel.dateDescription)
    }
    
    private func visualize() {
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    private func setupRX() {
        
        self.backBtn?.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.confirmBtn?.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.listener?.selectTime(model: wSelf.currentModel)
            wSelf.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.controllerDetail?.listener = self
        showLoading(use: indicator.asObservable().observeOn(MainScheduler.asyncInstance))
    }
}

// request api
extension DeliveryPickerTimeViewController {
    func requestTimesAvailable(date: String) {
        self.disposeRequest?.dispose()
        self.disposeRequest = self.token?.take(1).flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<DeliveryDateTimeResponse>.self, using: VatoExpressApi.listTimeAvailableDelivery(authToken: $0, date: date))
        }.observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(indicator)
            .subscribe(onNext: { [weak self] (r) in
                let datas: [String] = r.response.data?.availableTimes ?? []
                self?.controllerDetail?.reloadData(datas: datas)
                }, onError: { [weak self] (e) in
                    self?.controllerDetail?.reloadData(datas: [])
            })
    }
}

extension DeliveryPickerTimeViewController: DeliveryPickerTimeTVCListener {
    func didSelectDate(date: Date) {
        self.currentModel.date = date
        requestTimesAvailable(date: self.currentModel.dateDescription)
        timeLbl?.text = currentModel.string()
    }
    
    func didSelectTime(time: String) {
        self.currentModel.time = time
        timeLbl?.text = currentModel.string()
    }
    
}
