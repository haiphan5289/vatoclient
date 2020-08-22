//  File name   : InTripCell.swift
//
//  Author      : Dung Vu
//  Created date: 3/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX

// MARK: InTrip Driver Info
final class InTripDriverInfoCell: Eureka.Cell<DriverInfo>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = InTripDriverView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: DriverInfo?) {
        view.setupDisplay(item: item)
    }
}

// MARK: InTrip Contact Driver
final class InTripContactDriverCell: Eureka.Cell<Int>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = InTripContactView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: Int?) {
        view.iconMessage?.isHighlighted = (item ?? 0) > 0
    }
}


// MARK: InTrip Payment
final class InTripPaymentCell: Eureka.Cell<InTripPayment>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = InTripPaymentView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: InTripPayment?) {
        view.setupDisplay(item: item)
    }
    
    override func setup() {
        super.setup()
        height = { 92 }
    }
}

// MARK: InTrip Address
final class InTripAddressCell: Eureka.Cell<[String]>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = InTripAddressInfoView(frame: .zero)
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: [String]?) {
        view.setupDisplay(item: item)
    }
}

// MARK: InTrip Note
final class InTripNoteCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = InTripNoteView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: String?) {
        view.setupDisplay(item: item)
    }
}
