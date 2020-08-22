//  File name   : FoodWorkingHourView.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class FoodWorkingHourView: UIView {
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var containerView: UIView!
    @IBOutlet var colorMain: UIView?
    @IBOutlet var progressView: UIView?
    @IBOutlet var lblOpen: UILabel?
    @IBOutlet var lblClose: UILabel?
    
    private var percentTop: CGFloat = 0
    private var percentMain: CGFloat = 0
    
    @IBOutlet var tProgress: NSLayoutConstraint?
    @IBOutlet var hProgress: NSLayoutConstraint?
    /// Class's public properties.

    /// Class's private properties.
    func setupDisplay(item: FoodWorkingWeekDay?, range: ClosedRange<Int>?) {
        guard let item = item, let range = range, !range.isEmpty else {
            self.isHidden = true
            return
        }
        let day = item.day
        lblTitle?.text = day.name
        containerView.backgroundColor = day.colorBg
        colorMain?.backgroundColor = day.color
        let timeOpen = item.time.open
        let timeClose = item.time.close
        let strOpen = String(format: "%02d", timeOpen % 60)
        let strClose = String(format: "%02d", timeClose % 60)
        lblOpen?.text = "\(timeOpen / 60):\(strOpen)"
        lblClose?.text = "\(timeClose / 60):\(strClose)"
        
        
        let isToday: Bool
        if let today = FoodWeekDayType.today() {
            isToday = day == today
        } else {
            isToday = false
        }
        
        if !isToday {
            progressView?.backgroundColor = day.colorUnselect
            lblTitle?.alpha = 0.4
            lblOpen?.alpha = 0.4
            lblClose?.alpha = 0.4
            colorMain?.alpha = 0.6
        } else {
            progressView?.backgroundColor = day.color
            let font = UIFont.systemFont(ofSize: 14, weight: .medium)
            lblOpen?.font = font
            lblClose?.font = font
        }
        
        let total = range.count
        let time = timeClose - timeOpen
        percentTop = max(CGFloat(abs(timeOpen - range.lowerBound)) / CGFloat(total), 0)
        percentMain = CGFloat(time) / CGFloat(total)
    }
}

// MARK: Class's public methods
extension FoodWorkingHourView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension FoodWorkingHourView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let h = containerView.bounds.height
        tProgress?.constant = h * percentTop
        hProgress?.constant = h * percentMain
    }
}
