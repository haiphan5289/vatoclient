//  File name   : ButtonTimer.swift
//
//  Author      : Dung Vu
//  Created date: 12/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift

final class ButtonTimer: UIButton {
    /// Class's public properties.

    /// Class's private properties.
    private let timeInterval: TimeInterval
    private var expire: Date!
    private var disposeAble: Disposable?
    private lazy var disposeBag = DisposeBag()
    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        
        set {
            super.isEnabled = newValue
            newValue ? stopTimer() : startTimer()
        }
    }
    
    init(scheduleTimeInterval time: TimeInterval) {
        self.timeInterval = time
        super.init(frame: .zero)
//        setupRX()
    }

//    func setupRX() {
//        self.rx.tap.bind { [weak self] in
//            self?.isEnabled = false
//        }.disposed(by: disposeBag)
//    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startTimer() {
        disposeAble?.dispose()
        self.expire = Date(timeIntervalSinceNow: timeInterval)
        disposeAble = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).startWith(0).subscribe(onNext: { [weak self](_) in
            self?.checkChangeState()
        })
    }
    
    private func stopTimer() {
        disposeAble?.dispose()
    }
    
    private func checkChangeState() {
        let now = Date()
        guard now.timeIntervalSince1970 < expire.timeIntervalSince1970 - 2 else {
            self.isEnabled = true
            return
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: now, to: expire)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let message = String(format: "%02d: %02d", minute, second)
        self.setTitle(message, for: .disabled)
    }

    override func removeFromSuperview() {
        disposeAble?.dispose()
        super.removeFromSuperview()
    }
}
