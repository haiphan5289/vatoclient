//  File name   : TicketTimeVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import Eureka
import FwiCore
import FwiCoreRX

struct TimeDataGroup {
    enum TimeType: Int, CaseIterable {
        case morning
        case afternoon
        case night
        case midNight
        
        var stringType: String {
            switch self {
            case .morning:
                return Text.morning.localizedText
            case .afternoon:
                return Text.afternoon.localizedText
            case .night:
                return Text.night.localizedText
            case .midNight:
                return Text.midNight.localizedText
            }
        }
        
        /*
         Sáng   (12 am to 11'59 am)
         Chiều  (12 pm to 4'59 pm)
         Tối.     (5 pm to 8'59 pm)
         Khuya (9 pm to 11'59 pm )
         */
        var range: ClosedRange<Int> {
            switch self {
            case .morning:
                return "00:00".times()..."11:59".times()
            case .afternoon:
                return "12:00".times()..."16:59".times()
            case .night:
                return "17:00".times()..."20:59".times()
            case .midNight:
                return "21:00".times()..."24:59".times()
            }
        }
    
        var colorBgType: UIColor {
            switch self {
            case .morning:
                return #colorLiteral(red: 1, green: 0.9176470588, blue: 0.5529411765, alpha: 0.7)
            case .afternoon:
                return #colorLiteral(red: 0.8901960784, green: 0.4352941176, blue: 0.4745098039, alpha: 0.47)
            case .night:
                return #colorLiteral(red: 0.7098039216, green: 0.3843137255, blue: 0.568627451, alpha: 0.47)
            case .midNight:
                return #colorLiteral(red: 0.4823529412, green: 0.5568627451, blue: 0.7333333333, alpha: 0.74)
            }
        }
        
        var imageType: UIImage? {
            switch self {
            case .morning:
                return UIImage(named: "ic_morning")
            case .afternoon:
                return UIImage(named: "ic_afternoon")
            case .night:
                return UIImage(named: "ic_night")
            case .midNight:
                return UIImage(named: "ic_midnight")
            }
        }
        
        static func value(from minutes: Int?) -> TimeType? {
            guard let minutes = minutes else { return nil }
            for type in TimeType.allCases {
                guard type.range.contains(minutes) else {
                    continue
                }
                return type
            }
            return nil
        }
    }
    var type: TimeType
    var data: [TicketSchedules]
    
    init?(type: TimeType, data: [TicketSchedules]) {
        guard !data.isEmpty else {
            return nil
        }
        self.type = type
        self.data = data
    }
}

protocol TicketTimePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var ticketSchedulesObservable: Observable<[TicketSchedules]> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var error: Observable<BuyTicketPaymenState> { get }
    var ticketObservable: Observable<TicketInformation> { get }
    func ticketTimeMoveBack()
    func getListTime()
    func didSelectModel(model: TicketSchedules)
}

final class TicketTimeVC: UIViewController, TicketTimePresentable, TicketTimeViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let heightForHeaderInSection: CGFloat = 38.0
    }
    
    /// Class's public properties.
    weak var listener: TicketTimePresentableListener?
    internal lazy var contentView: UIView = UIView(frame: .zero)
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 63
        tableView.separatorStyle = .none
        
        view.backgroundColor = .white
        tableView.register(TicketTimeCellTableViewCell.nib, forCellReuseIdentifier: "TicketTimeCellTableViewCell")
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        return tableView
    }()
    private lazy var noItemView = NoItemView(imageName: "empty",
                                             message: Text.donotHaveDepartureTime.localizedText,
                                             on: self.tableView)
    private var timeDataGroup: [TimeDataGroup] = []
    internal lazy var panGesture: UIPanGestureRecognizer? = {
        let p = UIPanGestureRecognizer(target: nil, action: nil)
        p.delegate = self
        self.contentView.addGestureRecognizer(p)
        return p
    }()
    
    func showEmptySeatAlert(message: String) {
        AlertVC.showMessageAlert(for: self, title: Text.notification.localizedText, message: message, actionButton1: Text.dismiss.localizedText, actionButton2: nil)
    }
}

// MARK: View's event handlers
extension TicketTimeVC: UIGestureRecognizerDelegate {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        let t = tableView
        let shouldBegin = t.contentOffset.y <= -t.contentInset.top
        if shouldBegin {
            let velocity = panGesture?.velocity(in: view) ?? .zero
            return velocity.y > 0
        }
        return shouldBegin
    }
}

// MARK: Class's public methods
extension TicketTimeVC: DraggableViewProtocol {
    var containerView: UIView? {
        return contentView
    }
    
    func dismiss() {
        self.listener?.ticketTimeMoveBack()
    }
    
    func showCheckShowEmtyView() {
        self.tableView.numberOfSections > 0 ? noItemView.detach() : noItemView.attach()
    }
}

// MARK: Class's private methods
private extension TicketTimeVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = Color.black40
        contentView >>> view >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(view.layoutMarginsGuide.snp.top)
            }
        }
        
        let headerCorner = HeaderCornerView(with: 7)
        headerCorner.containerColor = .white
        headerCorner >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(61)
            }
        }
        
        let lblTitle = UILabel(frame: .zero)
        lblTitle >>> headerCorner >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = Text.departureTime.localizedText
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-18)
                
            }
        }
        
        let btnClose = UIButton(frame: .zero)
        btnClose >>> headerCorner >>> {
            $0.setImage(UIImage(named: "ic_close"), for: .normal)
            $0.backgroundColor = .clear
            $0.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 44))
            }
        }
        
        btnClose.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.ticketTimeMoveBack()
        })).disposed(by: disposeBag)
        
        tableView >>> contentView >>> {
            $0.showsVerticalScrollIndicator = false
            $0.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(headerCorner.snp.bottom)
            })
        }
        
        contentView.transform = CGAffineTransform(translationX: 0, y: 2000)
        guard let p = panGesture else {
            return
        }
        tableView.panGestureRecognizer.require(toFail: p)
    }
    
    private func setSelect() {
        self.listener?.ticketObservable.map { $0.scheduleId }.take(1).filterNil().delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (id, wSelf) in
            var indexPath: IndexPath?
            Finding: for i in  wSelf.timeDataGroup.enumerated() {
                let items = i.element.data
                guard let idx = items.lastIndex (where: { (s) -> Bool in
                    return s.id == id
                }) else {
                    continue
                }
                
                indexPath = IndexPath(item: idx, section: i.offset)
                break Finding
            }
            guard let index = indexPath else { return }
            wSelf.tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        })).disposed(by: disposeBag)
    }
   
    private func setupRX() {
        setupDraggable()
        self.rx.methodInvoked(#selector(viewWillAppear(_:))).take(1).bind(onNext: weakify({ (_, wSelf) in
            UIView.animate(withDuration: 0.3) {
                wSelf.contentView.transform = .identity
            }
        })).disposed(by: disposeBag)
        self.listener?.ticketSchedulesObservable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self] (ticketValue) in
            guard let wSelf = self else { return }
            var result: [TimeDataGroup.TimeType: [TicketSchedules]] = [:]
            
            ticketValue.forEach { schedule in
                let m = schedule.time?.times()
                guard let type = TimeDataGroup.TimeType.value(from: m) else {
                    return
                }
                var list = result[type] ?? []
                list.append(schedule)
                result[type] = list
            }
            
            wSelf.timeDataGroup = TimeDataGroup.TimeType.allCases.compactMap {
                let item = result[$0]
                return TimeDataGroup(type: $0, data: item ?? [])
            }
            
            wSelf.timeDataGroup.isEmpty ? wSelf.noItemView.attach() : wSelf.noItemView.detach()
            
            wSelf.tableView.reloadData()
            wSelf.setSelect()
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        listener?.error.bind(onNext: {[weak self] (errorType) in
            AlertVC.showError(for: self, message: errorType.getMsg())
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map({[weak self] in
            return self?.timeDataGroup[safe: $0.section]?.data[safe: $0.row]
        }).filterNil().bind { [weak self] model in
            self?.listener?.didSelectModel(model: model)
        }.disposed(by: disposeBag)
    }
}

extension TicketTimeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let timeDataGroup = self.timeDataGroup[section]
        
        let view = UIView.create {
            $0.backgroundColor = timeDataGroup.type.colorBgType
        }
        
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = timeDataGroup.type.stringType
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        
        UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.image = timeDataGroup.type.imageType
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.width.equalTo(32)
                    make.height.equalTo(32)
                    make.top.equalTo(8)
                })
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Config.heightForHeaderInSection
    }
    
}

extension TicketTimeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return timeDataGroup.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeDataGroup[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "TicketTimeCellTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TicketTimeCellTableViewCell else {
            fatalError("")
        }
        let timeDataGr = self.timeDataGroup[indexPath.section]
        let model = timeDataGr.data[indexPath.row]
        cell.setupDisplay(model: model, timeType: timeDataGr.type)
        return cell
    }
    
    
}
