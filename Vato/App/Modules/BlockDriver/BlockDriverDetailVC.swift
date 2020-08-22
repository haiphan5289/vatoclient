//  File name   : BlockDriverDetailVC.swift
//
//  Author      : admin
//  Created date: 6/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift


protocol BlockDriverDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func addBlockDriver(driver: BlockDriverInfo?)
    func removeBlockDriver(driver: BlockDriverInfo?)
    var driverObs: Observable<BlockDriverInfo> { get }
}

final class BlockDriverDetailVC: UIViewController, BlockDriverDetailPresentable, BlockDriverDetailViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: BlockDriverDetailPresentableListener?

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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBlock: UIButton!
    
    /// Class's private properties.
    private(set) lazy var disposeBag = DisposeBag()
    private var driver: BlockDriverInfo?
//    private var typeBlock: TypeBlock = .add
}

// MARK: View's event handlers
extension BlockDriverDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BlockDriverDetailVC {
}

// MARK: Class's private methods
private extension BlockDriverDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
                
        setUpTableView()
    }
    
    private func setupRX() {
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "back-w"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)

        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor =  #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.06666666667, alpha: 1)
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .lightContent)
        
        title = Text.driverInfo.localizedText
        
        btnBlock.rx.tap.bind {  [weak self] in
            self?.driver?.type == .add ? self?.listener?.addBlockDriver(driver: self?.driver) : self?.listener?.removeBlockDriver(driver: self?.driver)
        }.disposed(by: disposeBag)
        
        listener?.driverObs.bind(onNext: weakify { (d, wSelf) in
            wSelf.driver = d
            
            let txt = d.type == .add ? Text.blockDriver : Text.removeBlockDriver
            wSelf.btnBlock.setTitle(txt.localizedText.uppercased(), for: .normal)

            let dataSource = [("Full name", d.fullName), ("Phone number", d.phone)]
            Observable.just(dataSource).bind(to: wSelf.tableView.rx.items(cellIdentifier: "BlockCell", cellType: BlockCell.self)) { (row, element, cell) in
                cell.displayLayout(textStr: element.0, textDetail: element.1)
            }.disposed(by: wSelf.disposeBag)
        }).disposed(by: disposeBag)

    }
    
    private func setUpTableView() {
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        tableView.borderColor = .lightGray
        tableView.borderWidth = 0.5

        let cellIdentify = "BlockCell"
        tableView.register(BlockCell.self, forCellReuseIdentifier: cellIdentify)
        tableView.rowHeight = 50.0
    }
}

class BlockCell: UITableViewCell {
    
    private var lblInfo: UILabel?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel?.textColor = .gray
        textLabel?.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
                
        lblInfo = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        } >>> self.contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
            })
        }

        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayLayout(textStr: String, textDetail: String?) {
        textLabel?.text = textStr
        lblInfo?.text = textDetail
    }
}

enum TypeBlock: Int, Codable {
    case add
    case remove
}
