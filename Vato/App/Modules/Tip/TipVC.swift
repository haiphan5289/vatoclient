//  File name   : TipVC.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import RIBs
import RxSwift
import UIKit

protocol TipPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var tipStream: MutableTip { get }
    func closeTip()
    func update(tip: Double)
}

final class TipVC: UIViewController, TipPresentable, TipViewControllable {
    private lazy var disposeBag = DisposeBag()
    /// Class's public properties.
    weak var listener: TipPresentableListener?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var lblOriginalPrice: UILabel?
    @IBOutlet weak var lblTip: UILabel?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var btnReset: UIButton?
    @IBOutlet weak var lblTotal: UILabel?
    @IBOutlet weak var btnConfirm: UIButton?
    @IBOutlet weak var fareTripLabel: UILabel!
    @IBOutlet weak var tipDriverLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    private var dataSource = [PriceAddition]()
    private let subjectTip = Variable<UInt32>.init(0)
    private let subjectTotal = ReplaySubject<UInt32>.create(bufferSize: 1)
    private var tipConfig: TipConfig?
    private lazy var maxTip: UInt32 = {
        self.calculateMaxTip()
    }()

    private var originalPrice: UInt32 = 0

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        visualize()
        setupRX()
        makeDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }

        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.listener?.closeTip()
    }
}

// MARK: Class's public methods
extension TipVC {}

// MARK: Class's private methods
private extension TipVC {
    private func localize() {
        lblTitle?.text = "Tip" // Text.tipNow.localizedText
        fareTripLabel.text = Text.tripFare.localizedText
        tipDriverLabel.text = Text.tipDriver.localizedText
        btnReset?.setTitle(Text.reset.localizedText, for: .normal)
        totalLabel.text = Text.total.localizedText
        btnConfirm?.setTitle(Text.confirm.localizedText, for: .normal)
    }

    private func makeDataSource() {
        self.listener?.tipStream.configs.subscribe(onNext: { [weak self] tip in
            var source = tip.booking_price_additional.filter({ $0.active })
            // Check need round value
            let currentTip = self?.subjectTip.value ?? 0
            let mMoney = self?.originalPrice ?? 0
            let div = (mMoney + currentTip) / 1000
            let odd = div % 5
            RoundValue: if currentTip == 0 {
                guard odd != 0 else {
                    break RoundValue
                }
                let next: UInt32 = odd < 5 ? (5 - odd) : (10 - odd)
                let f: UInt32 = next * 1000
                var new = Array(source.dropFirst())
                new.insert(PriceAddition(active: true, price: f), at: 0)
                source = new
            }

            self?.dataSource = source
            self?.collectionView?.reloadData()
        }).disposed(by: disposeBag)
    }

    private func registerCell() {
        self.collectionView?.register(TipMoneyCollectionViewCell.nib, forCellWithReuseIdentifier: TipMoneyCollectionViewCell.identifier)
        self.collectionView?.rx.setDataSource(self).disposed(by: disposeBag)
        self.collectionView?.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
        self.btnConfirm?.apply(style: .default)
//        self.collectionView?.allowsMultipleSelection = true
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        self.listener?.tipStream.price.filterNil().subscribe(onNext: { [weak self] b in
            self?.originalPrice = b.service?.priceTotal ?? b.lastPrice
        }).disposed(by: disposeBag)

        self.listener?.tipStream.configs.subscribe(onNext: { [weak self] config in
            guard let wSelf = self else {
                return
            }
            wSelf.tipConfig = config
            wSelf.lblTitle?.text = config.booking_configure.message_in_peak_hours
        }).disposed(by: disposeBag)

        self.subjectTip.asObservable().bind { [weak self] v in
            self?.btnReset?.isHidden = v == 0
            // Calculate
            self?.calculateTotalPrice()
        }.disposed(by: disposeBag)

        self.listener?.tipStream.currentTip.map({ UInt32($0) }).bind(to: self.subjectTip).disposed(by: disposeBag)

        self.btnClose?.rx.tap.bind { [weak self] in
            self?.listener?.closeTip()
        }.disposed(by: disposeBag)

        self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).take(1).bind { [weak self] _ in
            UIView.animate(withDuration: 0.3, animations: {
                self?.containerView?.transform = CGAffineTransform.identity
            })
        }.disposed(by: disposeBag)

        self.collectionView?.rx.itemSelected.bind { [weak self] index in
            // Increase
            guard let wSelf = self else {
                return
            }

            let value = wSelf.subjectTip.value
            var needRefresh: Bool = index.item == 0
            defer {
                if needRefresh {
                    wSelf.makeDataSource()
                }
            }

            let max = wSelf.maxTip
            let item = wSelf.dataSource[index.item]
            let next = value + item.price
            guard next <= max else {
                needRefresh = false
                return
            }
            // Add more
            wSelf.subjectTip.value = next

        }.disposed(by: disposeBag)

        self.btnReset?.rx.tap.bind { [weak self] in
            self?.resetTip()
        }.disposed(by: disposeBag)

        self.btnConfirm?.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            let tip = wSelf.subjectTip.value
            wSelf.listener?.update(tip: Double(tip))
        }.disposed(by: disposeBag)
    }

    private func calculateMaxTip() -> UInt32 {
        guard let tipConfig = self.tipConfig, self.originalPrice > 0 else {
            return 0
        }
        let numberAllow = tipConfig.booking_configure.price_maximum_multi
        let priceMax = self.originalPrice * UInt32(numberAllow)
        return priceMax
    }

    private func resetTip() {
        self.subjectTip.value = 0
        makeDataSource()
    }

    private func calculateTotalPrice() {
        let totalTip = self.subjectTip.value
        self.listener?.tipStream.price.filterNil().subscribe(onNext: { [weak self] b in
            guard let wSelf = self else {
                return
            }
            
            let range = b.service?.rangePrice
            let min = range?.min ?? 0
            let max = range?.max ?? 0
            if b.service?.isGroupService == true,
                min != max {
                wSelf.lblOriginalPrice?.text = min.currency + "-" + max.currency
                wSelf.lblTotal?.text = (min + totalTip).currency + "-" + (max + totalTip).currency
                wSelf.lblTip?.text = totalTip.currency
                
            } else {
                wSelf.lblOriginalPrice?.text = min.currency
                wSelf.lblTotal?.text = (min + totalTip).currency
                wSelf.lblTip?.text = totalTip.currency
            }
        }).disposed(by: disposeBag)
    }
}

extension TipVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = TipMoneyCollectionViewCell.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        cell.lblValue?.text = dataSource[indexPath.item].description
        return cell
    }
}

extension TipVC: UICollectionViewDelegate {}
