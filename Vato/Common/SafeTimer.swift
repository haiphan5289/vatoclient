//
//  SafeTimer.swift
//  NowMerchant
//
//  Created by Huy Du on 9/3/18.
//  Copyright © 2018 Sea group. All rights reserved.
//

import Foundation

@objc public protocol SafeTimerDelegate: class {
    
    func safeTimerDidTrigger(_ safeTimer: SafeTimer)
}

@objc public class SafeTimer : NSObject {
    
    @objc public weak var delegate: SafeTimerDelegate?
    
    fileprivate var timer: Timer?
    fileprivate var timerTarget: TimerTarget
    
    public override init() {
        timerTarget = TimerTarget()
        super.init()
        timerTarget.delegate = self
    }
    
    deinit {
        invalidate()
    }
    
    @objc public var isValid: Bool {
        return timer?.isValid ?? false
    }
    
    @objc public func schedule(timeInterval: TimeInterval, repeats: Bool = false, userInfo: Any? = nil) {
        invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: timerTarget,
                                     selector: #selector(TimerTarget.didTriggerTimer(_:)),
                                     userInfo: userInfo, repeats: repeats)
    }
    
    @objc public func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

extension SafeTimer: TimerTargetDelegate {
    
    fileprivate func timerTargetDidTriggerTimer(_ timer: Timer) {
        
        if !timer.isValid {
            self.timer = nil
        }
        
        delegate?.safeTimerDidTrigger(self)
    }
}

// MARK: - TimerTarget

fileprivate protocol TimerTargetDelegate: class {
    func timerTargetDidTriggerTimer(_ timer: Timer)
}

fileprivate class TimerTarget {
    
    weak var delegate: TimerTargetDelegate?
    
    @objc func didTriggerTimer(_ timer: Timer) {
        delegate?.timerTargetDidTriggerTimer(timer)
    }
}
