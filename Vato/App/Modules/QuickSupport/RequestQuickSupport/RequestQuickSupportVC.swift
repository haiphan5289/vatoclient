//  File name   : RequestQuickSupportVC.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import FwiCoreRX
import AXPhotoViewer

enum QSFillInformationCellType: String, CaseIterable {
    case content = "Content"
    case title = "Title"
    case image = "Image"
}

struct ImageRequestModel {
    enum ImageRequestType {
        case image
        case addNew
    }
    var image: UIImage?
    let type: ImageRequestType
    
    init(image: UIImage?, type: ImageRequestType) {
        self.image = image
        self.type = type
    }
}


protocol RequestQuickSupportPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func openPhoto()
    func openCamera()
    func removePhoto(index: Int)
    var imagesObser: Observable<[UIImage]> { get }
    var requestModel: QuickSupportRequest { get }
    var inputModel: RequestModel { get set }
    func requestSupportMoveBack()
    func submit()
    func routeToListSupport()
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var defaultContent: String? { get }
}

final class RequestQuickSupportVC: FormViewController, RequestQuickSupportPresentable, RequestQuickSupportViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    
    
    private struct Config {
        static let maximumPhoto = 3
        
        static func genArgumentsAlert(title: String, content: String, image: String) -> AlertArguments {
            var arguments: AlertArguments = [:]
            
            let titleStyle = AlertLabelValue(text: title, style: AlertStyleText(color: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), font: UIFont.systemFont(ofSize: 18, weight: .medium), numberLines: 2, textAlignment: .center))
            arguments[.title] = titleStyle
            
            let messagerStyle = AlertLabelValue(text: content, style: AlertStyleText(color: #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1), font: UIFont.systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center))
            arguments[.message] = messagerStyle
            
            let imageStyle = AlertImageValue(imageName: image, style: AlertImageStyle(contentMode: .scaleAspectFill, size: CGSize(width: 94, height: 80)))
            
            arguments[.image] = imageStyle
            return arguments
        }
        
        static func genCloseButtonAlert(title: String, handler: @escaping AlertBlock) -> AlertAction {
            let styleBtn = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)
            
            let actionButton = AlertAction(style: styleBtn, title: Text.dismiss.localizedText, handler: handler)
            return actionButton
        }
    }
    
    /// Class's public properties.
    weak var listener: RequestQuickSupportPresentableListener?

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

    /// Class's private properties.
    
    private var viewBgNext: UIView?
    private var submitBtn: UIButton?
    private var isLoading = false
    lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension RequestQuickSupportVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension RequestQuickSupportVC {
    func showError(eror: Error) {
        AlertVC.showError(for: self, error: eror as NSError)
    }

    func showAlertSuccess() {
        let arguments = Config.genArgumentsAlert(title: Text.titleSupportRequestSuccess.localizedText,
                                 content: Text.messageSupportRequestSuccess.localizedText,
                                 image: "ic_request_success")

        let actionButton = Config.genCloseButtonAlert(title: Text.dismiss.localizedText) { [weak self] in
            self?.listener?.routeToListSupport()
        }
        let buttons: [AlertAction] = [actionButton]
        
        AlertCustomVC.show(on: self, option: .all, arguments: arguments, buttons: buttons, orderType: .horizontal)
    }
    
    func showAlertFail(message: String) {
        let msg = !message.isEmpty ? message : Text.messageSupportRequestFail.localizedText
        let arguments = Config.genArgumentsAlert(title: Text.titleSupportRequestFail.localizedText,
                                                 content: msg,
                                                 image: "ic_request_error")
        
        let actionButton = Config.genCloseButtonAlert(title: Text.dismiss.localizedText, handler: {})
        let buttons: [AlertAction] = [actionButton]
        
        AlertCustomVC.show(on: self, option: .all, arguments: arguments, buttons: buttons, orderType: .horizontal)
    }
}

// MARK: Class's private methods
private extension RequestQuickSupportVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        self.title = listener?.requestModel.title
        
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
        leftButton.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.requestSupportMoveBack()
        }.disposed(by: disposeBag)
        
        // todo: Visualize view's here.
        UIView.performWithoutAnimation {
            self.form += [gensection()]
        }
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let _viewBgNext = UIView(frame: .zero) >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                make.height.equalTo(78)
            })
        }
        
        // table view
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalTo(_viewBgNext.snp.top)
                
            })
        }
        
        let button = UIButton(frame: .zero)
        button >>> _viewBgNext >>> {
            $0.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), state: .normal)
            $0.setBackground(using: .gray, state: .disabled)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle(Text.quickSupport.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(10)
                make.height.equalTo(48)
            })
        }
        self.submitBtn = button
        submitBtn?.isEnabled = false
        viewBgNext = _viewBgNext
    }
    
    private func gensection() -> Section   {
        
        self.tableView.separatorStyle = .none
        
        let section = Section("") { (s) in
            s.tag = "InputInfor"
            // header
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.height = { 0.01   }
            s.header = header
        }
        
        // title
        section <<< RowDetailGeneric<RequestQuickSupportInputCell>.init(QSFillInformationCellType.title.rawValue, { (row) in
            row.cell.update(title: Text.title.localizedText, placeHolder: Text.enterTitle.localizedText)
            row.add(ruleSet: RulesTitle.rules(minimumCharacter: 4))
            row.cell.textField.rx.text.bind { [weak self] (_) in
                self?.listener?.inputModel.title = row.value
            }.disposed(by: disposeBag)
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = Text.messageVerifyTitleQuickSupport.localizedText
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        
        // content
        section <<< RowDetailGeneric<RequestQuickSupportTextViewCell>.init(QSFillInformationCellType.content.rawValue, { (row) in
            row.cell.update(title: Text.content.localizedText, placeHolder: Text.messageEnterContentQuickSupport.localizedText)
            row.add(ruleSet: RulesTitle.rules(minimumCharacter: 6))
            row.cell.setText(self.listener?.defaultContent)
            row.cell.defaultContent = self.listener?.defaultContent
            row.cell.textView.rx.text.bind { [weak self] (_) in
                self?.listener?.inputModel.content = row.value
            }.disposed(by: disposeBag)
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = Text.messageVerifyContentQuickSupport.localizedText
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        
        section <<< RowDetailGeneric<RequestQuickSupportImageCell>.init(QSFillInformationCellType.image.rawValue, { [weak self] (row) in
            row.cell.update(title: Text.messageAttackImageQuickSupport.localizedText)
            row.cell.didSelectAdd = { [weak self] in self?.showActionSheetPhoto() }
            row.cell.didSelectClear = { [weak self] indexPath in self?.listener?.removePhoto(index: indexPath.row) }
        })
        return section
    }

    private func setupRX() {
        self.listener?.imagesObser.subscribe(onNext: { [weak self] (_images) in
            guard let imageCell = self?.form.rowBy(tag: QSFillInformationCellType.image.rawValue) as? RowDetailGeneric<RequestQuickSupportImageCell> else { return }
            imageCell.cell.reloadData(_images: _images)
        }).disposed(by: disposeBag)
        
        self.submitBtn?.rx.tap.bind(onNext: { [weak self] (_) in
            guard self?.isLoading == false else { return }
            self?.listener?.submit()
        }).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            UIView.animate(withDuration: d.duration, animations: {
                self?.viewBgNext?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-d.height)
                })
                self?.view.layoutIfNeeded()
            })
        }.disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
    }
    
    private func showActionSheetPhoto() {
        let optionMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: Text.openCamera.localizedText, style: .default, handler:{ [weak self] (_) in
            self?.listener?.openCamera()
        })
        let saveAction = UIAlertAction(title: Text.shoosePicturesFromPhoto.localizedText, style: .default, handler:{ [weak self] (_) in
            self?.listener?.openPhoto()
        })
        let cancelAction = UIAlertAction(title: Text.cancel.localizedText, style: .cancel)
        
        optionMenuController.addAction(addAction)
        optionMenuController.addAction(saveAction)
        optionMenuController.addAction(cancelAction)
        
        self.present(optionMenuController, animated: true, completion: nil)
    }
    
    func validate(row: BaseRow?) {
        let errors = form.validate()
        self.submitBtn?.isEnabled = errors.isEmpty
    }
    
}
