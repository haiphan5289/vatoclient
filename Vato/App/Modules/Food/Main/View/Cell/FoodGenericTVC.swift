//  File name   : FoodGenericTVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import FwiCoreRX
import SnapKit
import RxSwift

protocol DisplayStaticHeightProtocol {
    static var height: CGFloat { get }
    static var bottom: CGFloat { get }
    static var automaticHeight: Bool { get }
}

protocol HandlerValueProtocol {
    associatedtype E
    var callback: BlockAction<E>? { get set }
}

protocol LazyDisplayImageProtocol {
    func displayImage()
}

private class CachedNib {
    static let shard = CachedNib()
    private var views: [String: UINib] = [:]
    private let queue = DispatchQueue(label: "com.vato.loadNib", qos: .background)
    func load<T: UIView>() -> T {
        let key = "\(T.self)"
        if let result = views[key]?.instantiate(withOwner: nil, options: nil).first as? T {
            return result
        } else {
            let nib = T.nib
            views[key] = nib
            guard let result = queue.sync(execute: { nib?.instantiate(withOwner: nil, options: nil).first as? T }) else {
                fatalError("Please implement!!!")
            }
            return result
        }
    }
}

final class FoodGenericTVC<T: UIView>: UITableViewCell, UpdateDisplayProtocol, LazyDisplayImageProtocol, CleanActionProtocol where T: UpdateDisplayProtocol, T: DisplayStaticHeightProtocol, T: LazyDisplayImageProtocol {
    typealias Value = T.Value
    let view: T = CachedNib.shard.load()
    static var identifier: String {
        return "\(self)_\(T.self)"
    }
    
    func setupDisplay(item: Value?) {
        self.view.setupDisplay(item: item)
    }
    
    func displayImage() {
        view.displayImage()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else {
            return
        }
        common()
    }
    

    /// Class's private properties.
    private func common() {
        selectionStyle = .none
        clipsToBounds = true
        contentView.clipsToBounds = true
        view >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                if !T.automaticHeight {
                    make.height.equalTo(T.height)
                }
                make.bottom.equalTo(T.bottom).priority(.high)
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func cleanAction() {
        (view as? CleanActionProtocol)?.cleanAction()
    }
}


