//  File name   : TicketDetailRouteVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift
import FwiCore

enum TypeAddressImage {
    case destination(last: Bool)
    case other
    
    var img: UIImage? {
        switch self {
        case .destination(let last):
            return last ? UIImage(named: "ic_destination_new") : UIImage(named: "ic_origin")
        default:
            return UIImage(named: "ic_destination_light")
        }
    }
    
    var showDot: Bool {
        switch self {
        case .destination(let last):
            return !last
        default:
            return true
        }
    }
    
    static func load(index: IndexPath, total: Int) -> TypeAddressImage {
        switch index.item {
        case 0:
            return .destination(last: false)
        default:
            return index.item < total - 1 ? .other : .destination(last: true)
        }
    }
    var textColor: UIColor {
        switch self {
        case .destination(let last):
            return last ? #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        default:
            return #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
    }
}

protocol TicketDetailRoutePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func ticketDetailRouteMoveBack()
    var itemDetailRouteInfo: Observable<DetailRouteInfo> {get}
}

final class TicketDetailRouteVC: UIViewController, TicketDetailRoutePresentable, TicketDetailRouteViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketDetailRoutePresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    @IBOutlet weak var lbInfoTrip: UILabel!
    @IBOutlet weak var lbSupport: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbNameFrom: UILabel!
    @IBOutlet weak var lbNameTo: UILabel!
    private lazy var noItemView = NoItemView(imageName: "empty", message: Text.donotHaveTicket.localizedText, on: tableView)
    private var itemDetail: DetailRouteInfo?
    private let disposeBag = DisposeBag()
    @IBOutlet weak var btCall: UIButton!

    /// Class's private properties.
}

// MARK: View's event handlers
extension TicketDetailRouteVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketDetailRouteVC {
}

// MARK: Class's private methods
private extension TicketDetailRouteVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // left button
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.hidesBackButton = true
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.ticketDetailRouteMoveBack()
        }).disposed(by: disposeBag)
        
        title = Text.detailRoute.localizedText
        
        self.lbInfoTrip.text = Text.informationTrip.localizedText
        
        var att = Text.desDetailRoute.localizedText.attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .regular))

        let s1 = "19006667".attribute
            >>> .color(c: #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 12.0, weight: .regular))
        
        att = att >>> s1
        
        self.lbSupport.attributedText = att
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.register(TicketDetailRouteCell.nib, forCellReuseIdentifier: TicketDetailRouteCell.identifier)
    }
    private func setupRX() {
        self.listener?.itemDetailRouteInfo.bind(onNext: weakify { (item, wSelf) in
            guard let count = item.listDetailRoute?.count else {
                wSelf.noItemView.attach()
                return
            }
            
            count > 0 ? wSelf.noItemView.detach() : wSelf.noItemView.attach()
            wSelf.itemDetail = item
            //wSelf.itemDetail?.listDetailRoute?.sort(by: { $0.duration < $1.duration })
            wSelf.tableView.reloadData()
            wSelf.lbNameFrom.text = item.nameFrom
            wSelf.lbNameTo.text = item.nameTo
        }).disposed(by: disposeBag)
        
        self.btCall.rx.tap.bind { _ in
            if let url = URL(string: "tel://\(19006667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }.disposed(by: disposeBag)
    }
}
extension TicketDetailRouteVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        
        let lbTimeHeader: UILabel = UILabel(frame: .zero)
        lbTimeHeader.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbTimeHeader.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lbTimeHeader.text = Text.timeTrip.localizedText

        v.addSubview(lbTimeHeader)

        lbTimeHeader.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(35)
        }
        
        let lbPlaceHeader: UILabel = UILabel(frame: .zero)
        lbPlaceHeader.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbPlaceHeader.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lbPlaceHeader.text = Text.location.localizedText

        v.addSubview(lbPlaceHeader)

        lbPlaceHeader.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(16)
            make.left.equalTo(lbTimeHeader.snp.right).offset(10)
        }
        
        return v
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension TicketDetailRouteVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.itemDetail?.listDetailRoute?.count else {
            return 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketDetailRouteCell.identifier) as! TicketDetailRouteCell
        
        
        if let detail = self.itemDetail?.listDetailRoute?[indexPath.row] {
            indexPath.row == 0 ? cell.updateUIFirstRow(model: detail) : cell.updateUI(model: detail,
                                                                        departureDate: self.itemDetail?.departureDate ?? "",
                                                                        departureTime: self.itemDetail?.departureTime ?? "")
        }
        
        if let count = self.itemDetail?.listDetailRoute?.count  {
            let type = TypeAddressImage.load(index: indexPath, total: count)
            cell.imgAddress.image = type.img
            cell.imgDot.isHidden = !type.showDot
            cell.lbName.textColor = type.textColor
         }
        return cell
    }
}
