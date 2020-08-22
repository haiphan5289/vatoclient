//
//  ReasonCancelVC.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork
import FwiCoreRX
import Alamofire
import SnapKit
import FirebaseFirestore

var dataSourceCache = [ReasonCancelModel]()
class ReasonCancelVC: UIViewController {
    
    @objc var didSelectConfirm: ((_ param: [String: Any]) -> Void)?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    /// Class's private properties.
    private(set) lazy var disposeBag = DisposeBag()
    private var dataSource: [ReasonCancelModel] = []
    
    private var lblSubTitle: UILabel!
    private var viewFooter: UIView!
    private var tfNote: UITextField!
    
    private var isShowFooter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        contentTableView.sectionHeaderHeight = UITableView.automaticDimension
        contentTableView.estimatedSectionHeaderHeight = 50
        createFooterView()
        setRX()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visulize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tfNote.resignFirstResponder()
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        UIApplication.setStatusBar(using: .lightContent)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setRX() {
        self.contentTableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.contentTableView.rx.setDataSource(self).disposed(by: disposeBag)
        self.contentTableView.register(UINib(nibName: "ReasonCancelTVC", bundle: nil), forHeaderFooterViewReuseIdentifier: "ReasonCancelTVC")
        
        self.contentTableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            
            wSelf.btnConfirm.isEnabled = true
            wSelf.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            
            let count = wSelf.dataSource.count
            if indexPath.row == count - 1 {
                wSelf.contentTableView.tableFooterView = wSelf.viewFooter
                wSelf.tfNote.becomeFirstResponder()
                
                if (wSelf.tfNote.text ?? "").trim().isEmpty {
                    wSelf.btnConfirm.isEnabled = false
                    wSelf.btnConfirm.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                } else {
                    wSelf.btnConfirm.isEnabled = true
                    wSelf.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
                }
            }
            }.disposed(by: disposeBag)
        
        self.contentTableView.rx.itemDeselected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            let count = wSelf.dataSource.count
            if indexPath.row == count - 1 {
                wSelf.contentTableView.tableFooterView = nil
                wSelf.tfNote.resignFirstResponder()
            }
            }.disposed(by: disposeBag)
        
        self.btnConfirm.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            
            let datas = wSelf.dataSource
            
            guard let indexPath: IndexPath =  wSelf.contentTableView.indexPathForSelectedRow else { return }
            
            var result: [String : Any] = [:]
            
            let row = indexPath.row
            let reason = datas[row]
            if row != datas.count - 1 {
                result = ["end_reason_id": reason.id ?? 0,
                          "end_reason_value": reason.description ?? ""]
            } else {
                let note = (wSelf.tfNote.text ?? "").trim()
                result = ["end_reason_id": reason.id ?? 0,
                          "end_reason_value": note]
            }
            
            self?.dismiss(animated: true, completion: nil)
            self?.didSelectConfirm?(result)
            }.disposed(by: disposeBag)
        
        self.btnClose.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        setupKeyboardAnimation()
    }
    
    private func requestData() {
        
        if (dataSourceCache.count > 0) {
            self.dataSource = dataSourceCache
            return;
        }
        let documentRef = Firestore.firestore().collection("ConfigData").document("Client").collection("CancellationReasons")
        documentRef.getDocuments { [weak self](snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                return
            }
            for document in snapshot.documents {
                let idString = document.get("id") as? Int //Getting a nil error
                let descriptionString = document.get("description") as? String
                
                let reason = ReasonCancelModel(id: idString, description: descriptionString)
                dataSourceCache.append(reason)
            }
            self?.dataSource = dataSourceCache
            
            DispatchQueue.main.async {
                self?.contentTableView.reloadData()
            }
        }
    }
    
    private func createFooterView() {
        viewFooter = UIView.create {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 90))
            $0.backgroundColor = .white
        }
        
        let label = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Color.battleshipGrey
            $0.text = Text.detailDescription.localizedText
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        
        tfNote = UITextField.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.borderStyle = .none
            $0.placeholder = Text.detailProblem.localizedText
            $0.returnKeyType = .done
            $0.delegate = self
            $0.addTarget(self, action: #selector(self.textFieldDidChange(sender:)), for: .editingChanged)
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.top.equalTo(label.snp.bottom).offset(8)
                    make.height.equalTo(24)
                })
        }
        
        UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            } >>> viewFooter >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(0)
                    make.top.equalTo(tfNote.snp.bottom).offset(8)
                    make.height.equalTo(1)
                })
        }
    }
    
    private func visulize() {
        lblTitle.text = Text.reasonCancel.localizedText
        btnConfirm.setTitle(Text.submitTheReason.localizedText, for: .normal)
        btnConfirm.setTitle(Text.submitTheReason.localizedText, for: .disabled)
    }
    
}

extension ReasonCancelVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ReasonCancelTVC"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ReasonCancelTVC
        if cell == nil {
            cell = ReasonCancelTVC.newCell(reuseIdentifier: identifier)
        }
        
        let item = dataSource[indexPath.row]
        cell?.visulizeCell(with: item.description)
        
        return cell!
    }
}

extension ReasonCancelVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.create {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 50))
            $0.backgroundColor = .white
        }
        
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            // $0.text = "Vui lòng cho Vato biết lý do huỷ chuyến. Phản hồi của bạn rất quý cho chúng tôi."
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            
            let attr = NSMutableAttributedString(string: Text.cancellationDescription.localizedText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
            $0.attributedText = attr
            
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.top.equalTo(20)
                    make.bottom.equalTo(0)
                })
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return isShowFooter ? 90 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return isShowFooter ? viewFooter : nil
    }
}

extension ReasonCancelVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfNote.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        let textTrim = (tfNote.text ?? "").trim()
        if textTrim.count > 250 {
            tfNote.text = String(textTrim.substring(toIndex: 250) )
        }
        if textTrim.isEmpty {
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        } else {
            self.btnConfirm.isEnabled = true
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
    }
}

extension ReasonCancelVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return contentTableView
    }
}
