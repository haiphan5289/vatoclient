//  File name   : TicketChooseDestinationVC.swift
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
import FwiCoreRX
import SnapKit
import FwiCore

protocol TicketChooseDestinationPresentableListener: class {
    var listPlaceObservable: Observable<[TicketDestinationPoint]>  { get }
    var loading: Observable<(Bool,Double)>  { get }
    func getListPoint(with type: DestinationType, originCode: String?)
    func update(type: DestinationType, point: TicketLocation)
    func moveBack()
    var errorObserableOriginLocation: Observable<TicketChooseDestinationErrType> {get}
    var errorObserableDestinationLocation: Observable<TicketChooseDestinationErrType>{get}
}

final class TicketChooseDestinationVC: UIViewController, TicketChooseDestinationPresentable, TicketChooseDestinationViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    lazy var disposeBag = DisposeBag()
    
    /// Class's public properties.
    weak var listener: TicketChooseDestinationPresentableListener?
    
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var searchControl: UISearchBar!
    private var destinationType: DestinationType = .origin
    private var currentCode: String?
    private var originCode: String?
    private var dataSource: Variable<[TicketDestinationPoint]> = Variable([])
    private lazy var noItemViewOriginLocation = NoItemView(imageName: "empty",
                                             message: Text.donotHaveOriginLocation.localizedText,
                                             on: self.contentTableView)
    private lazy var noItemViewDestinationLocation = NoItemView(imageName: "empty",
                                                           message: Text.donotHaveDestinationLocation.localizedText,
                                                           on: self.contentTableView)
    
    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, param: ChooseDestinationParam) {
        self.destinationType = param.destinationType
        self.currentCode = self.destinationType == .origin ? param.originCode : param.destinationCode
        self.originCode = param.originCode
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        registerCell()
        setupRX()
        
        if self.destinationType == .origin {
            self.listener?.getListPoint(with: .origin, originCode: nil)
        } else {
            self.listener?.getListPoint(with: .destination, originCode: self.originCode)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupNavigation()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension TicketChooseDestinationVC {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketChooseDestinationVC {
}

// MARK: Class's private methods
private extension TicketChooseDestinationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.title = destinationType.title
        searchControl.placeholder = Text.searchLocation.localizedText
        contentTableView.keyboardDismissMode = .onDrag
        contentTableView.tableFooterView = UIView()
    }
    
    private func registerCell() {
        self.contentTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    }
    
    private func setupRX() {
        
        self.listener?.listPlaceObservable.subscribe(onNext: { [weak self] (array) in
            self?.dataSource.value = array
        }).disposed(by: disposeBag)
        
        self.searchControl?.rx.text
            .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (keyWord) in
                self?.filterPoint(with: keyWord)
            })
            .disposed(by: disposeBag)
        
        self.searchControl.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)

        self.dataSource.asObservable().bind(to: contentTableView.rx.items(cellIdentifier: "PlaceCell", cellType: UITableViewCell.self)) { [weak self] (row, element, cell) in
            guard let wSelf = self else { return }
            if wSelf.destinationType == .origin {
                cell.textLabel?.text = element.originName
                
            } else {
                cell.textLabel?.text = element.destName
            }
            
            let imageView = (cell.contentView.viewWithTag(768) as? UIImageView).orNil({ 
                let i = UIImageView(image: UIImage(named: "ic_checkedbox"))
                i >>> cell.contentView >>> {
                    $0.tag = 768
                    $0.snp.makeConstraints { (make) in
                        make.centerY.equalToSuperview()
                        make.size.equalTo(CGSize(width: 22, height: 22))
                        make.right.equalTo(-16)
                    }
                }
                i.isHidden = true
                return i
            }())
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            
            if wSelf.destinationType == .origin {
                if element.originCode == wSelf.currentCode {
                    cell.contentView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
                    imageView.isHidden = false
                } else {
                    cell.contentView.backgroundColor = .white
                    imageView.isHidden = true
                }
            } else {
                if element.destCode == wSelf.currentCode {
                    cell.contentView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
                    imageView.isHidden = false
                } else {
                    cell.contentView.backgroundColor = .white
                    imageView.isHidden = true
                }
            }
        }.disposed(by: disposeBag)
        
        self.contentTableView?.rx.itemSelected.bind {[weak self](indexPath) in
            guard let wSelf = self else { return }
            let model = wSelf.dataSource.value[indexPath.row]
            switch wSelf.destinationType{
            case .origin:
                guard let originCode = model.originCode,
                    let originName = model.originName else { return }
                let result = TicketLocation(code: originCode, name: originName)
                wSelf.listener?.update(type: wSelf.destinationType, point: result)
            case .destination:
                guard let destCode = model.destCode,
                    let destName = model.destName else { return }
                let result = TicketLocation(code: destCode, name: destName)
                wSelf.listener?.update(type: wSelf.destinationType, point: result)
            }
        }.disposed(by: disposeBag)
        self.listener?.errorObserableOriginLocation.bind(onNext: { [weak self] (err) in
            switch err {
            case .success:
                self?.noItemViewOriginLocation.detach()
            case .noData:
                self?.noItemViewOriginLocation.attach()
            case .err:
                AlertVC.showError(for: self, message: Text.checkNetworkBad.localizedText)
            }
        }).disposed(by: disposeBag)
        self.listener?.errorObserableDestinationLocation.bind(onNext: { [weak self] (err) in
            switch err {
            case .success:
                self?.noItemViewDestinationLocation.detach()
            case .noData:
                self?.noItemViewDestinationLocation.attach()
            case .err:
                AlertVC.showError(for: self, message: Text.checkNetworkBad.localizedText)
            }
        }).disposed(by: disposeBag)

        showLoading(use: self.listener?.loading)

    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
    }
    
    private func filterPoint(with keyword: String?) {
        self.listener?.listPlaceObservable.subscribe(onNext: { [weak self] (array) in
            guard let wSelf = self, let kWord = keyword?.lowercased().forSorting else { return }
            if kWord == "" {
                wSelf.dataSource.value = array
            } else {
                if wSelf.destinationType == .origin {
                    wSelf.dataSource.value = array.filter { $0.originName?.lowercased().forSorting.contains(kWord) ?? false || $0.originCode?.lowercased().forSorting.contains(kWord) ?? false }
                } else {
                    wSelf.dataSource.value = array.filter { $0.destName?.lowercased().forSorting.contains(kWord) ?? false || $0.destCode?.lowercased().forSorting.contains(kWord) ?? false }
                }
            }
        }).disposed(by: disposeBag)
    }
}

extension String {
    var forSorting: String {
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "").replacingOccurrences(of: "Đ", with: "").replacingOccurrences(of: "đ", with: "d")
    }
}
