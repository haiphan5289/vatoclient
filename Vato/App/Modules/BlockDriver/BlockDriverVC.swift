//  File name   : BlockDriverVC.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol BlockDriverPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func addBlockDriver()
    var blackListObser: Observable<[BlockDriverInfo]> { get }
    func goToDetailDriver(driver: BlockDriverInfo)
}

final class BlockDriverVC: UIViewController, BlockDriverPresentable, BlockDriverViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: BlockDriverPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setUpRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
        
//    @IBOutlet weak var btnClose: UIButton!
//    @IBOutlet weak var btnBlock: UIButton!
//    @IBOutlet weak var lblBlock: UILabel!
    
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var lblBlock: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgDriver: UIImageView!
    
    /// Class's private properties.
    private(set) lazy var disposeBag = DisposeBag()
    private var listDriver: [BlockDriverInfo]?
}

// MARK: View's event handlers
extension BlockDriverVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
}

// MARK: Class's public methods
extension BlockDriverVC {
}

// MARK: Class's private methods
private extension BlockDriverVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        
        UIApplication.setStatusBar(using: .lightContent)
        
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "close-w"), for: .normal)
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
        title = Text.blacklist.localizedText
        
        btnBlock.setTitle(Text.blockDriver.localizedText.uppercased(), for: .normal)
        lblBlock.text = Text.blockDriverMess.localizedText
        
        setUpTableView()
    }
    
    private func setUpTableView() {
        tableView.backgroundColor = .white

        let cellIdentify = "BlockDriverCell"
        tableView.register(BlockDriverCell.self, forCellReuseIdentifier: cellIdentify)
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
    }

    private func setUpRX() {
        btnBlock.rx.tap.bind {  [weak self] in
            self?.listener?.addBlockDriver()
        }.disposed(by: disposeBag)
        
        listener?.blackListObser.bind(onNext: weakify { (list, wSelf) in
            wSelf.listDriver = list
            
            if list.count == 0 {
                wSelf.tableView.isHidden = true
                wSelf.lblBlock.isHidden = false
                wSelf.imgDriver.isHidden = false
            }
            else {
                wSelf.tableView.isHidden = false
                wSelf.lblBlock.isHidden = true
                wSelf.imgDriver.isHidden = true
                
                Observable.just(list).bind(to: self.tableView.rx.items(cellIdentifier: "BlockDriverCell", cellType: BlockDriverCell.self)) { (row, element, cell) in
                    cell.displayLayout(driver: element)
                    cell.accessoryType = .disclosureIndicator
                }.disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind { (idx) in
            if let list = self.listDriver {
                var d = list[idx.row]
                d.type = .remove
                self.listener?.goToDetailDriver(driver: list[idx.row])
            }
        }.disposed(by: disposeBag)
    }
}

class BlockDriverCell: UITableViewCell {
    
    private var lblInfo: UILabel?
    private var iconImageView: UIImageView?
    private var separatorView: UIView?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        imageView?.snp.makeConstraints{(make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel?.snp.makeConstraints { (make) in
            make.left.equalTo(imageView!.snp.right).offset(16)
            make.centerY.equalToSuperview().offset(-8)
        }
                
        lblInfo = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = .gray
        } >>> self.contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(textLabel!.snp.left)
                make.top.equalTo(textLabel!.snp.bottom).offset(3)
            })
        }
        
        separatorView = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09839898768)
        }
        >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(1.0)
                make.left.equalTo(textLabel!.snp.left)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(0.5)
            })
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayLayout(driver: BlockDriverInfo) {
//        imageView?.setImage(from: driver.avatarUrl, placeholder: UIImage(named: "ic_default_avatar"), size: CGSize(width: 40, height: 40))
        imageView?.image = UIImage(named: "ic_default_avatar")
        textLabel?.text = driver.fullName
        lblInfo?.text = driver.phone
    }
}



