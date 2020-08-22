//
//  TicketDestinationDetailVC.swift.swift
//  Vato
//
//  Created by vato. on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import VatoNetwork

import SnapKit

enum TicketDestinationType: Int {
    case chooseLocation = 0
    case chooseTime = 1
    case chooseTimeReturn = 2
}

protocol TicketDestinationDetailVCListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var ticketObservable: Observable<TicketInformation>? { get }
    var popularRoutes: Observable<[PopularRoute]>? { get }
    var isRoundTrip: Observable<Bool>? { get }
    
    func routeToStartLocation()
    func routeToDestinationLocation()
    func routeToChooseDate()
    func routeToChooseDateReturn()
    func selectOnOffRoundStrip(isRoudtrip: Bool)
    func routeToHistory()
    func didSelectItemDepart(item: TicketHistoryType?)
    func swapLocation()
    func routeToFillInformation()
    func didSelectPopularRoute(route: PopularRoute?)
    func getRouteId(route: PopularRoute)
    func getRouteInfo(routeId: Int, route: PopularRoute, date: String?, time: String?, wayId: Int?)
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable, T : Encodable
}

struct TicketResponse: InitializeValueProtocol, ResponsePagingProtocol {
    var data: [PopularRoute]?
    var pageSize: Int
    
    var items: [PopularRoute]? {
        return data
    }
    
    var next: Bool {
        return (items?.count ?? 0) >= pageSize
    }
}

class TicketDestinationDetailVC: UIViewController, RouteDelegate {
    struct Config {
        static let kPrefixImageViewFooter = "bgr_ticket_footer"
        static let kTimeImageDuration = 5
        static let dateFormat = "EEE, dd/MM, yyyy"
    }
    
    private lazy var disposeBag = DisposeBag()
    weak var listener: TicketDestinationDetailVCListener? {
        didSet {
            setUpListView()
        }
    }
    
    @IBOutlet weak var findTicketLabel: UILabel?
    @IBOutlet weak var pickAddressLabel: UILabel!
    @IBOutlet weak var destinationTextlabel: UILabel!
    @IBOutlet weak var dateStartTextLabel: UILabel!
    
    @IBOutlet weak var selectOriginButton: UIButton!
    @IBOutlet weak var selectDestButton: UIButton!
    @IBOutlet var buttonSwap: UIButton?
    
    @IBOutlet weak var originAddressLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var roundTripLabel: UILabel!
    @IBOutlet weak var roundTripSwitch: UISwitch!
    @IBOutlet weak var dateReturnLabel: UILabel!
    @IBOutlet weak var dateRoundTripLabel: UILabel!
    @IBOutlet weak var btnChooseOriginAddress: UIButton?
    @IBOutlet weak var btnChooseDestinationAddress: UIButton?
    
    @IBOutlet weak var findRouteBtn: UIButton!
    @IBOutlet weak var locationView: UIView?
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var imvBanner: UIImageView!
    @IBOutlet weak var roundTripDateView: UIView!
    
    private var currentSelectedIndex: IndexPath?
    private var ticketHistoryType: TicketDetailModel?
    private lazy var headerSegmentView = TicketHeaderSegmentView(frame: .zero)
    
    var model: [TicketHistoryType]?
    var totalTicket = 1
    private lazy var sourceBanner: ReplaySubject<[BannerProtocol]> = ReplaySubject.create(bufferSize: 1)
    private lazy var footerView: FoodBannerView = {
        let view = FoodBannerView.loadXib()
        view.roundAll = true
        return view
    }()
    
    @VariableReplay private var source: [PopularRoute] = []
    @VariableReplay private var typeRoute: TypeRoute = .all
    typealias Route = (origin: String?, destination: String?)
    private var selectedRoute: Route?
    private weak var btnFilter: UIButton?
    private var disposeSelect: Disposable?
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 5)
        v.containerColor = .white
        v.corners = .allCorners
        return v
    }()
    
    private var listView: PagingListView<PopularRouteTVC, TicketDestinationDetailVC, P>?
    private var tableView: UITableView? {
        return listView?.tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        roundTripLabel.text = Text.roundTrip.localizedText
        visualize()
        self.pickAddressLabel.text = Text.departure.localizedText
        self.destinationTextlabel.text = Text.destination.localizedText
        self.dateStartTextLabel.text = Text.dateDeparture.localizedText
                       
        buttonSwap?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    // MARK: - Table view data source, delegate

    private func showDetail(item: TicketDetailModel) {
        guard let routeId = item.routeId else { return }
        let i = PopularRoute(description: nil, destCode: item.destCode, destName: item.destName, originCode: item.originCode, originName: item.originName, promotion: nil, distance: nil, duration: nil, name: nil, price: nil, totalSchedule: nil)
        let date = item.departureDate
        let time = item.departureTime
        
        listener?.getRouteInfo(routeId: routeId, route: i, date: date, time: time, wayId: item.wayId)
    }
     
    func updataData(model: TicketInformation) {
            
        if let originName = model.originLocation?.name {
            self.originAddressLabel.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            self.originAddressLabel.text = originName
        } else {
            self.originAddressLabel.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.38)
            self.originAddressLabel.text = Text.tapToSelect.localizedText
        }
        
        if let destName = model.destinationLocation?.name {
            self.destinationLabel.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            self.destinationLabel.text = destName
        } else {
            self.destinationLabel.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.38)
            self.destinationLabel.text = Text.tapToSelect.localizedText
        }
        
        self.dateLabel.text = model.date?.string(from: Config.dateFormat) ?? ""
    }
    
    func updateReturnData(model: TicketInformation) {
        self.dateRoundTripLabel.text = model.date?.string(from: Config.dateFormat) ?? ""
    }
    
    func setupRX() {
        headerSegmentView.eDetail.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.showDetail(item: item)
        })).disposed(by: disposeBag)
        
        headerSegmentView
            .segmentView
            .selected
            .bind(onNext: {[weak self] (route) in
            self?.listener?.didSelectItemDepart(item: route)
        }).disposed(by: disposeBag)
        
        self.selectOriginButton.rx.tap.bind { [weak self] (_) in
            self?.listener?.routeToChooseDate()
        }.disposed(by: disposeBag)
        
        self.selectDestButton.rx.tap.bind { [weak self] (_) in
            self?.listener?.routeToChooseDateReturn()
        }.disposed(by: disposeBag)
        
        btnChooseOriginAddress?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToStartLocation()
        })).disposed(by: disposeBag)
        
        btnChooseDestinationAddress?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToDestinationLocation()
        })).disposed(by: disposeBag)
        
        roundTripSwitch
            .rx
            .controlEvent(.valueChanged)
            .withLatestFrom(roundTripSwitch.rx.value)
            .subscribe(onNext : {[weak self] value in
                self?.roundTripDateView.isHidden = !value
                self?.listener?.selectOnOffRoundStrip(isRoudtrip: value)
                
            })
            .disposed(by: disposeBag)
        
        buttonSwap?.rx.tap.bind(onNext: {[weak self] (_) in
            self?.listener?.swapLocation()
        }).disposed(by: disposeBag)
        
        listener?.ticketObservable?
            .bind(onNext: {[weak self] (model) in
                self?.buttonSwap?.isEnabled = model.verifyToChooseBusStatus()
            }).disposed(by: disposeBag)
        
        findRouteBtn.rx.tap.bind {[weak self] _ in
            self?.listener?.routeToFillInformation()
        }.disposed(by: disposeBag)
        
        listener?.ticketObservable?
            .bind(onNext: {[weak self] (model) in
                self?.updataData(model: model)
                if model.verifyToChooseBusStatus() == false  {
                    self?.findRouteBtn.isEnabled = false
                    self?.findRouteBtn.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
                } else {
                    self?.findRouteBtn.isEnabled = true
                    self?.findRouteBtn.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
                }
            }).disposed(by: disposeBag)
        
        BannerManager.instance.requestBanner(type: VatoServiceAction.buyTicket.rawValue).bind(onNext: weakify({ (list, wSelf) in
            wSelf.sourceBanner.onNext(list)
        })).disposed(by: disposeBag)
        
        sourceBanner.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (list, wSelf) in
            guard !list.isEmpty else {
                return
            }
            
            let v = UIView(frame: .zero)
            v.backgroundColor = .clear
            
            wSelf.footerView >>> v >>> {
                $0.setupDisplay(item: list)
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.height.equalTo(66)
                    make.bottom.equalToSuperview().priority(.high)
                })
                
                $0.callback = { [weak self] item in
                    guard let item = item as? BannerProtocol, let url = item.url else {
                        return
                    }
                    WebVC.loadWeb(on: self, url: url, title: nil)
                }
            }
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
        })).disposed(by: disposeBag)
    }
    
    func updateData(model: [TicketHistoryType]?, totalTicket: Int)  {
        let items = model?.filter { $0.status == .success } ?? []
        self.model = items
        self.totalTicket = items.count
        if items.isEmpty {
            headerSegmentView.isHidden = true
        } else {
            headerSegmentView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 200))
            headerSegmentView.isHidden = false
            headerSegmentView.backgroundColor = .white
            headerSegmentView.segmentView.setupDisplay(item: self.model)
            headerSegmentView.setupDisplayTitle(totalTicket: self.totalTicket)
        }
        updateHeaderTableView()
    }
    
    private func checkSelect() {
        disposeSelect?.dispose()
        if let currentSelectedIndex = self.currentSelectedIndex {
            self.tableView?.deselectRow(at: currentSelectedIndex, animated: false)
            self.currentSelectedIndex = nil
            self.selectedRoute = nil
        }
        
        // Check
        guard let e1 = self.listener?.ticketObservable?.take(1) else {
            return
        }
        
        let e2 = $source.filter{ !$0.isEmpty }.take(1).delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        disposeSelect = Observable.zip(e1, e2) { [weak self](ticket, source) -> IndexPath? in
            let originCode = ticket.originLocation?.code
            let destinationCode = ticket.destinationLocation?.code
            self?.selectedRoute = (originCode, destinationCode)
            
            // Try to find select promotion
            var temp: PopularRoute?
            var idx: Int?
            
            source.enumerated().forEach { (item) in
                let element = item.element
                guard element.originCode == originCode && element.destCode == destinationCode else {
                    return
                }
                
                Finding: if let t = temp {
                    let d1 = t.discount
                    let d2 = element.discount
                    guard d1 < d2 else {
                        break Finding
                    }
                    temp = element
                    idx = item.offset
                } else {
                    temp = element
                    idx = item.offset
                }
            }
            
            // Find item promotion
            guard let index = idx else {
                return nil
            }
            return IndexPath(item: index, section: 0)
        }.filterNil().bind(onNext: weakify({ (idx, wSelf) in
            guard let r = wSelf.tableView?.numberOfRows(inSection: 0), r > idx.item else { return }
            wSelf.tableView?.selectRow(at: idx, animated: true, scrollPosition: .middle)
            wSelf.currentSelectedIndex = idx
        }))
    }
    
    func updateSelectedPopularRoute(type: DestinationType, point: TicketLocation?) {
        checkSelect()
    }
    
    func tableViewOnDidSelect(_ indexPath: IndexPath, item: PopularRoute) {
        selectedRoute = nil
        if let currentIndex = currentSelectedIndex, currentIndex != indexPath {
            self.tableView?.cellForRow(at: currentIndex)?.setSelected(false, animated: false)
            self.tableView?.deselectRow(at: currentIndex, animated: false)
        }
        
        currentSelectedIndex = indexPath
        
        self.listener?.didSelectPopularRoute(route: item)
    }
    
    func selectPopularRouteAtIndex(index: Int) {
        $source.filter { !$0.isEmpty }.take(1).bind(onNext: weakify({ (list, wSelf) in
            guard let item = list[safe: index]  else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                wSelf.tableViewOnDidSelect(IndexPath(row: index, section: 0), item: item)
                wSelf.tableView?.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            }
        })).disposed(by: disposeBag)
    }
        
    func moveToDetailRoute(route: PopularRoute) {
        listener?.getRouteId(route: route)
    }
}

extension TicketDestinationDetailVC: RequestInteractorProtocol {
    var token: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil().take(1)
    }
}

private extension TicketDestinationDetailVC {

    private func visualize() {
        // todo: Visualize view's here.
        title = Text.buyTicket.localizedText
        self.originAddressLabel.text = Text.tapToSelect.localizedText
        self.destinationLabel.text = Text.tapToSelect.localizedText
        self.originAddressLabel.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.38)
        self.destinationLabel.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.38)
        
        self.dateLabel.text = Date().string(from: Config.dateFormat)
        self.dateRoundTripLabel.text = Date().string(from: Config.dateFormat)
        self.findTicketLabel?.text = Text.findTrip.localizedText
        findRouteBtn.setTitle(FwiLocale.localized("Tìm vé"), for: .normal)
               
        self.view.backgroundColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)
        
        locationView?.backgroundColor = .clear
        locationView?.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.themeUpdateUI()
    }
    
    private func setUpListView() {
        let pagingView = PagingListView<PopularRouteTVC, TicketDestinationDetailVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> TicketDestinationDetailVC.P in
            return Paging(page: -1, canRequest: true, size: 10)
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_quick_support_empty",
                              message: Text.noData.localizedText,
                              subMessage: "",
                              on: tableView,
                              customLayout: nil)
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(viewDate.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(imvBanner.snp.top)
            }
        }
        pagingView.clipsToBounds = true
        
        pagingView.selected.bind(onNext: weakify({ (route, wSelf) in
            wSelf.selectRoute(route: route)
        })).disposed(by: disposeBag)
        
        pagingView.configureCell = { [weak self] cell, item in
            guard let wSelf = self else { return }
            cell.delegate = wSelf
        }
        
        pagingView.willDisplayCell = { [weak self] cell, index , item in
            guard let wSelf = self else { return }
            cell?.setupDisplayContainerView(idx: index.item)
            if let old = wSelf.currentSelectedIndex  {
                cell?.setSelected(old == index, animated: false)
            } else {
                let selected = item.compare(route: wSelf.selectedRoute)
                guard selected else {
                    cell?.setSelected(false, animated: false)
                    return
                }
                cell?.setSelected(selected, animated: false)
                wSelf.currentSelectedIndex = index
            }
        }
        
        self.listView = pagingView
    }
    
    private func updateHeaderTableView() {
        let v = listView?.tableView.tableHeaderView ?? visualizeHeaderListView()
        let h: CGFloat = headerSegmentView.isHidden ? 40.0 : 230.0
        let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: h), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        v.frame = CGRect(origin: .zero, size: s)
        listView?.tableView.tableHeaderView = v
    }
    
    private func visualizeHeaderListView() -> UIView {
        let view = UIView()

        view.backgroundColor = .white
        let label = UILabel(frame: .zero)
        
        label >>> view >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = Text.popularRoutes.localizedText
            $0.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
            }
        }
        
        let btFilter: UIButton = UIButton(frame: .zero)
        btFilter >>> view >>> {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            $0.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            $0.setTitle(typeRoute.name, for: .normal)
            $0.semanticContentAttribute = .forceRightToLeft
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            $0.setImage(UIImage(named: "ic_form_droplist"), for: .normal)
            $0.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
            $0.imageView?.snp.makeConstraints({ (make) in
                make.top.right.equalToSuperview()
                make.width.height.equalTo(20)
            })
        }
        
        btFilter.rx.tap.bind { [weak self] (_) in
            guard let wSelf = self else { return }
            wSelf.showFilter()
        }.disposed(by: disposeBag)
        btnFilter = btFilter
                
        let stackView = UIStackView(arrangedSubviews: [headerSegmentView, view]) >>> {
                        $0.spacing = 5
                        $0.axis = .vertical
                    }
        return stackView
    }
    
    private func showFilter() {
        let menuSource = Observable.just(TypeRoute.allCases)
        VatoActionSheetVC<TicketMenuTVC>.showUse(source: menuSource, on: self, currentSelect: self.$typeRoute.asObservable(), title: Text.popularRoutes.localizedText)
            .filterNil()
            .bind(onNext: ({ [weak self] (route)  in
                guard let wSelf = self, wSelf.typeRoute != route else { return }
                wSelf.typeRoute = route
                if wSelf.currentSelectedIndex != nil {
                    wSelf.currentSelectedIndex = nil
                }
                
                if route == .all {
                    // Reset
                    wSelf.source = []
                }
                wSelf.listView?.refresh()
                wSelf.btnFilter?.setTitle(wSelf.typeRoute.name, for: .normal)
            })).disposed(by: disposeBag)
    }
    
    private func selectRoute(route: PopularRoute) {
        let currentItems = self.source
        if let idx = currentItems.index(of: route) {
            tableViewOnDidSelect(IndexPath(item: idx, section: 0), item: route)
        }
    }
}

extension TicketDestinationDetailVC: TicketHeaderViewListener {
    func didSelectItemDepart(item: TicketDisplayProtocol?) {
//        listener?.didSelectItemDepart(item: self.model)
    }
}

extension TicketDestinationDetailVC: ThemeManagerHandlerProtocol {
    func themeUpdateUI() {
        imvBanner.stopAnimating()
        var listsImage = ThemeManager.instance.loadListPDF(by: Config.kPrefixImageViewFooter)
        if listsImage.isEmpty, let image = ThemeManager.instance.loadPDFImage(name: Config.kPrefixImageViewFooter) {
            listsImage.append(image)
        }
        let h = listsImage.isEmpty ? 0 : 64
        imvBanner?.snp.updateConstraints({ (make) in
            make.height.equalTo(h)
        })
        
        let animate = listsImage.count > 1
        if animate {
            imvBanner.animationImages = listsImage
            imvBanner.animationDuration = TimeInterval(Config.kTimeImageDuration * listsImage.count)
            imvBanner.animationRepeatCount = 0
            imvBanner.startAnimating()
        } else {
            imvBanner.image = listsImage.first
        }
    }
}

// MARK: -- Setup Paging List
extension TicketDestinationDetailVC : PagingListRequestDataProtocol {
    typealias Data = TicketResponse
    typealias P = Paging
    
    func request(router: APIRequestProtocol, decodeTo: TicketResponse.Type) -> Observable<TicketResponse> {
        guard let listener = listener else {
            return Observable.empty()
        }
        
        if typeRoute == .promotion {
            return $source.map { list in
                let newList = list.filter { $0.promotion?.code != nil }
                let i = TicketResponse(data: newList, pageSize: 200)
                return i
            }
        }
        
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        }).do(onNext: { [weak self](res) in
            guard let wSelf = self else { return }
            let news = res.items ?? []
            let old = wSelf.source
            wSelf.source = old + news
        })
    }
        
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let filter = $typeRoute.take(1).map { ["page": paging.page, "size": paging.size, "type": $0.rawValue] }
        return filter.flatMap { [weak self](params) -> Observable<APIRequestProtocol> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            let url = "\(VatoTicketApi.host)/buslines/futa/routes/customize-routes"
            return wSelf.request { key -> Observable<APIRequestProtocol> in
                return Observable.just(VatoAPIRouter.customPath(authToken: key, path: url, header: ["token_type":"user"], params: params, useFullPath: true))
            }
        }
    }
}

