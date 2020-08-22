//  File name   : ProfileVC.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import SnapKit
import FwiCore
import FwiCoreRX

enum ProfileCellType: String, CaseIterable {
    case registerMerchant
    case headerDetail
    case promotion
    case locationFavorite
    case blocked
    case inviteFriend
    case royalPoints
    case quickSupport
    // case support
    case groupVato
    case registerVato
    case notification
    
    static var allCases: [ProfileCellType] {
        #if DEBUG
           return [.headerDetail, .notification, .promotion, .locationFavorite, .blocked, .royalPoints, .groupVato, .registerVato]
        #else
            return [.headerDetail, .notification, .promotion, .locationFavorite, .blocked, .royalPoints, .groupVato, .registerVato]
        #endif
    }
    
    var image: UIImage? {
        switch self {
        case .royalPoints:
            return UIImage(named: "ic_score_p")
        case .promotion:
           return UIImage(named: "ic_home_voucher")
        case .locationFavorite:
            return UIImage(named: "ic_place_p")
        case .blocked:
            return UIImage(named: "ic_block_p")
        case .inviteFriend:
            return UIImage(named: "ic_referral_p")
//        case .support:
//            return UIImage(named: "ic_support_p")
        case .groupVato:
            return UIImage(named: "ic_group_p")
        case .registerVato:
            return UIImage(named: "ic_register_p")
        case .headerDetail:
            return nil
        case .registerMerchant:
            return UIImage(named: "ic_register_p")
        case .quickSupport:
            return UIImage(named: "ic_quick_support")
        case .notification:
            return UIImage(named: "ic_notification")
        }
    }
    
    var title: String? {
        switch self {
        case .royalPoints:
            return Text.royalPoints.localizedText
        case .promotion:
            return Text.promotion.localizedText
        case .locationFavorite:
            return Text.favoriteSaved.localizedText
        case .blocked:
            return Text.blacklist.localizedText
        case .inviteFriend:
            return Text.referralFriend.localizedText
//        case .support:
//            return Text.support.localizedText
        case .groupVato:
            return Text.groupVato.localizedText
        case .registerVato:
            return Text.registerVato.localizedText
        case .headerDetail:
            return nil
        case .registerMerchant:
            return Text.registerMerchant.localizedText
        case .quickSupport:
            return Text.quickSupport.localizedText
        case .notification:
            return Text.notification.localizedText
        }
    }
    
    var isDotViewHidden: Bool {
       switch self {
        case .registerMerchant:
            return false
        default:
            return true
        }
    }
}

protocol ProfilePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var user: Observable<UserInfo> { get }
    func doSignOut()
    func showListPromotion()
    func showInviteFriend()
    func didSelectFavoritePlace()
    func didSelectBlock()
    func didSelectSupport()
    func didSelectGroupVato()
    func didSelectRegisterVato()
    func didSelectRegisterMerchant()
    func didSelectQuickSupport()
    func profileMoveBack()
    var badgeQuicSupport :Observable<Int?> { get }
    func requestBadgeQuicksupport()
    func didSelectNotification()
}

final class ProfileVC: FormViewController, ProfilePresentable, ProfileViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ProfilePresentableListener?
    private var profileViewModel: FCHomeViewModel!
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        profileViewModel = FCHomeViewModel(viewModle: self)
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.listener?.requestBadgeQuicksupport()
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.setStatusBar(using: .lightContent)
    }
    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat {
        switch s {
        case 0:
            return 10
        default:
            return 5
        }
    }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}

// MARK: View's event handlers
extension ProfileVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ProfileVC: ProfileDetailDelegate {
    func profileSignOut() {
        let signOut: BlockAction<Void> = { [weak self] _  in
            self?.listener?.doSignOut()
        }
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true, completion: signOut)
        } else {
            signOut(())
        }
    }
}

// MARK: Class's private methods
private extension ProfileVC {
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
        title = Text.tabbarProfile.localizedText
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
            btn.setImage(UIImage(named: "ic_close_vato"), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
            let rightView = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = rightView
            
            button.rx.tap.bind { [weak self] in
                self?.listener?.profileMoveBack()
            }.disposed(by: disposeBag)
            
            btn.rx.tap.bind { [weak self] in
                self?.listener?.profileMoveBack()
            }.disposed(by: disposeBag)
        }
        
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
            })
        }
        
        let appConfig = AppConfig.default
        let version = appConfig.appInfor?.version ?? ""
        let build = appConfig.appInfor?.build ?? ""
        let text = "\(Text.version.localizedText) \(version) | \(build)"
        let contentView = UIView(frame: .zero)
        let lblVersion = UILabel(frame: .zero)
        lblVersion >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.text = text
        }
        lblVersion.sizeToFit()
        let s = lblVersion.frame.size
        lblVersion >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalTo(16)
            })
        }
        contentView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: s.height))
        tableView.tableFooterView = contentView
        
        let section1 = Section("")
        let section2 = Section("")
        ProfileCellType.allCases.forEach { (type) in
            switch type {
            case .headerDetail:
                section1 <<< RowDetailGeneric<ProfileHeaderCell>.init(type.rawValue, { (row) in
                    row.onCellSelection({ [weak self](_, _) in
                        self?.handler(type: type)
                    })
                })
            #if DEBUG
            #elseif STAGING
            #else
            case .registerMerchant:
                break
            #endif
            default:
                section2 <<< RowDetailGeneric<ProfileServiceCell>.init(type.rawValue, { (row) in
                    row.value = type
                    row.onCellSelection({ [weak self](_, _) in
                        self?.handler(type: type)
                    })
                })
            }
        }
        
        UIView.performWithoutAnimation {
            self.form += [section1, section2]
        }
    }
    
    private func showProfileDetail() {
        guard let profileVC = UIStoryboard(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileDetailViewController") as? ProfileDetailViewController else {
            return
        }
        
        profileVC.delegate = self
        profileVC.homeViewModel = profileViewModel
        let controller = FacecarNavigationViewController(rootViewController: profileVC)
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .coverVertical
        self.present(controller, animated: true, completion: nil)
    }
    
    private func handler(type: ProfileCellType) {
        switch type {
        case .royalPoints:
            guard let vc = UIStoryboard(name: "CreditPoint", bundle: nil).instantiateInitialViewController() else {
                fatalError("Please Implement")
            }
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            navi.modalTransitionStyle = .coverVertical
            self.present(navi, animated: true, completion: nil)
        case .headerDetail:
            showProfileDetail()
        case .promotion:
            listener?.showListPromotion()
        case .inviteFriend:
            listener?.showInviteFriend()
        case .locationFavorite:
            self.listener?.didSelectFavoritePlace()
        case .blocked:
            self.listener?.didSelectBlock()
//        case .support:
//            listener?.didSelectSupport()
        case .groupVato:
            listener?.didSelectGroupVato()
        case .registerVato:
            listener?.didSelectRegisterVato()
        case .registerMerchant:
            #if DEBUG
                listener?.didSelectRegisterMerchant()
            #elseif STAGING
                listener?.didSelectRegisterMerchant()
            #else
                break
            #endif
        case .quickSupport:
            listener?.didSelectQuickSupport()
        case .notification:
            listener?.didSelectNotification()
        }
    }
    
    func setupRX() {
        self.listener?.user.bind(onNext: weakify({ (user, wSelf) in
            let row = wSelf.form.rowBy(tag: ProfileCellType.headerDetail.rawValue) as? RowDetailGeneric<ProfileHeaderCell>
            row?.value = user
        })).disposed(by: disposeBag)
        
        self.listener?.badgeQuicSupport.bind(onNext: { [weak self] (_number) in
            let number = _number ?? 0
            let row = self?.form.rowBy(tag: ProfileCellType.quickSupport.rawValue) as? RowDetailGeneric<ProfileServiceCell>
            row?.cell.badgeLabel?.isHidden = (number <= 0)
            row?.cell.badgeLabel?.text = number > 99 ? "99+" : "\(number)"
        }).disposed(by: disposeBag)
    }
}
