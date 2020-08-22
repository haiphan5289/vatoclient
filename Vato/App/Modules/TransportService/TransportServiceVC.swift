//  File name   : TransportServiceVC.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import RIBs
import RxSwift
import UIKit
import FwiCoreRX

protocol TransportServicePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eFixedBook: Observable<Bool> { get }
    var selectdEvent: Observable<ServiceCanUseProtocol> { get }
    var source: Observable<[TransportGroup]> { get }
    var currentPromotion: PromotionModel? { get }
    var currentBook: Booking? { get }
    func updateSelect(service: ServiceCanUseProtocol)
    func closeTransPortService()
}

final class TransportServiceVC: UIViewController, TransportServicePresentable, TransportServiceViewControllable {
    struct TransportServiceConfig {
        static let hHeader: CGFloat = 32
    }

    /// Class's public properties.
    weak var listener: TransportServicePresentableListener?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var panGesture: UIPanGestureRecognizer?
    @IBOutlet weak var topContainer: NSLayoutConstraint?
    private var dataSource = [TransportGroup]() {
        didSet {
            loadContainer.onNext(())
        }
    }
    private(set) lazy var disposeBag = DisposeBag()
    private var isFixedBook: Bool = true
    private var currentTransform: CGAffineTransform?
    private lazy var loadContainer: ReplaySubject<Void> = ReplaySubject.create(bufferSize: 1)

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        loadContainer.take(1).observeOn(MainScheduler.asyncInstance).bind { [weak self] in
            self?.loadContainerView()
        }.disposed(by: disposeBag)
        
        
    }
    
    private func loadContainerView() {
        let items = dataSource.flatMap { $0.services }
        let hItem = CGFloat(items.count) * 70
        let hHeader = TransportServiceConfig.hHeader * CGFloat(dataSource.count)
        let hContainer = hItem + hHeader + 100
        let delta = max((UIScreen.main.bounds.height - hContainer), 80)
        let top = delta
        self.topContainer?.constant = top
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        
//        let h = self.containerView?.frame.height ?? 0
//        let currentH = dataSource.reduce(0) { (v1, transport) -> Int in
//            return v1 + transport.services.count * 70
//        }
//        let delta = TransportServiceConfig.hHeader * CGFloat(dataSource.count)
//        let v = max(h - (CGFloat(currentH) + delta), 0)
//        UIView.animate(withDuration: 0.3) {
//            self.containerView?.transform = CGAffineTransform(translationX: 0, y: v)
//        }
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
        self.listener?.closeTransPortService()
    }
}

// MARK: Table View DataSource
extension TransportServiceVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TransportServiceTVC.dequeueCell(tableView: tableView)
        cell.visualize(with: dataSource[indexPath.section].services[indexPath.item],
                       isFixedBook: self.isFixedBook,
                       modelPromotion: self.listener?.currentPromotion,
                       currentBook: self.listener?.currentBook)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].services.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
}

// MARK: Table View Delegate
extension TransportServiceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UIButton(frame: .zero)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.contentHorizontalAlignment = .left
        label.setTitleColor(Color.battleshipGreyTwo, for: .normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.contentEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 0)
        label.setTitle(dataSource[section].name, for: .normal)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransportServiceConfig.hHeader
    }
}

extension TransportServiceVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard let tableView = self.tableView  else {
            return true
        }
        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
        return shouldBegin
    }
}

// MARK: Class's private methods
private extension TransportServiceVC {
    private func localize() {
        titleLabel?.text = Text.chooseServices.localizedText
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1500)
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        setupDraggable()
        self.listener?.eFixedBook.subscribe(onNext: { [weak self] v in
            self?.isFixedBook = v
        }).disposed(by: disposeBag)

        self.listener?.source.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] s in
            self?.dataSource = s
            self?.tableView?.reloadData()
            self?.selectItem()
        }).disposed(by: disposeBag)
        self.tableView?.rx.setDataSource(self).disposed(by: disposeBag)
        self.tableView?.rx.setDelegate(self).disposed(by: disposeBag)

        self.tableView?.rx.itemSelected.bind { [weak self] index in
            guard let wSelf = self else {
                return
            }
            let service = wSelf.dataSource[index.section][index.item]
            wSelf.listener?.updateSelect(service: service)
        }.disposed(by: disposeBag)
        
        guard let p = panGesture else {
            return
        }
        
        p.delegate = self
        self.tableView?.panGestureRecognizer.require(toFail: p)
    }

    private func selectItem() {
        self.listener?.selectdEvent.take(1).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] s in
            guard let wSelf = self, wSelf.dataSource.count > 0 else {
                return
            }

            wSelf.dataSource.enumerated().forEach({ e in
                guard let index = e.element.index(of: s) else {
                    return
                }
                let indexPath = IndexPath(item: index, section: e.offset)
                wSelf.tableView?.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            })
        }).disposed(by: disposeBag)
    }

    private func registerCell() {
        self.tableView?.register(TransportServiceTVC.nib, forCellReuseIdentifier: TransportServiceTVC.identifier)
    }
}

extension TransportServiceVC: DraggableViewProtocol {
    func dismiss() {
        self.listener?.closeTransPortService()
    }
}
