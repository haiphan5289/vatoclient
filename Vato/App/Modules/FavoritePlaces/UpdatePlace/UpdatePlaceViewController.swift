//
//  UpdatePlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FwiCoreRX
import VatoNetwork
import Alamofire

import RIBs

enum UpdatePlaceMode {
    case create
    case update
    case quickCreate
}
class UpdatePlaceViewController: UIViewController, LoadingAnimateProtocol,  DisposableProtocol {
    var needReloadData: (() -> Void)?
    
    var modeSubject = BehaviorSubject<UpdatePlaceMode>(value: UpdatePlaceMode.create)
    var viewModel: UpdatePlaceVM!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    // MARK: - property
    @IBOutlet private weak var nameTextField: TextField!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var buttonActionAddress: UIButton!
    @IBOutlet weak var saveAddressButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewButtonDelete: UIView!
    @IBOutlet weak var viewButtonConfirm: UIView!
    @IBOutlet weak var viewButtons: UIView!
    internal lazy var disposeBag = DisposeBag()
    var auth: AuthenticatedStream?
    private var listSection = [FavoritePlaceSection.Fav, FavoritePlaceSection.Other]
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private var updatePlaceRouting: UpdatePlaceRouting!
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.nameTextField.placeholder = Text.nameOfPlace.localizedText
        self.saveAddressButton.setTitle(Text.savePlace.localizedText, for: .normal)
        self.deleteButton.setTitle(Text.deletePlace.localizedText, for: .normal)
        self.nameLabel.text = Text.name.localizedText
        self.addressLabel.text = Text.address.localizedText
        
        self.nameLabel.text = Text.name.localizedText
        self.addressTextLabel.text = Text.address.localizedText
        fillData()
        setRX()
        self.setupKeyboardAnimation()
        
        updatePlaceRouting = UpdatePlaceRouting()
        updatePlaceRouting?.listener = self
    }

    convenience init(mode: UpdatePlaceMode, viewModel: UpdatePlaceVM?) {
        self.init()
        self.modeSubject.onNext(mode)
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        self.addressLabel.text = viewModel.getAddress()
        fillData()
    }
    
    // MARK: - Private method
    private func setupNavigationBar() {
        self.title = Text.favoritePlace.localizedText
        
        // left button
        var imageLeftButton = UIImage(named: "back-w")
        imageLeftButton = imageLeftButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeftButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func setRX(){
        if self.viewModel.model?.address == nil {
            viewButtonDelete.removeFromSuperview()
            viewButtonDelete = nil
            self.nameTextField.becomeFirstResponder()
        }
        self.navigationItem.leftBarButtonItem?.rx.tap
            .bind { [weak self] (_) in
                self?.dismissViewController()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.updatePlaceRouting.deactive()
                }
            }
            .disposed(by: disposeBag)
        
        self.deleteButton.rx.tap.bind { [weak self] (_) in
            self?.confirmDeleteFavAddress()
            }
            .disposed(by: disposeBag)
        
        self.modeSubject.subscribe { mode in
            if mode.element == .create || mode.element == .quickCreate {
                self.title = Text.addFavoritePlace.localizedText
            } else {
                self.title = Text.updateFavoritePlace.localizedText
                //                self.statusNameView.backgroundColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 0.1)
            }
            }.disposed(by: disposeBag)
        
        self.nameTextField.rx.text
            .subscribe(onNext: { [weak self] keyword in
                self?.viewModel.updateName(name: keyword)
                self?.checkEnableButtonConfirm()
            })
            .disposed(by: disposeBag)
        
        self.buttonActionAddress.rx.tap
            .bind { [weak self] (_) in
                guard let wSelf = self else { return }
                guard let model = wSelf.viewModel.model, let auth = wSelf.auth else { return }
                let vc = wSelf.updatePlaceRouting.presentViewController(model: model, authenticated: auth)
                wSelf.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        self.saveAddressButton.rx.tap
            .subscribe(){ [weak self]event in
                guard let self = self else { return }
                self.checkCreateOrUpdate()
            }
            .disposed(by: disposeBag)
        
        showLoading(use: trackProgress.asObservable())
    }
    
    func checkCreateOrUpdate() {
        self.modeSubject.take(1).subscribe(onNext: {[weak self] mode in
            guard let self = self else { return }
            if mode == .update && self.viewModel.model?.id != nil {
                self.updateFavAddress()
            } else {
                self.createFavAddress()
            }

        }).disposed(by: disposeBag)
    }
    
    func createFavAddress() {
        guard let model = self.viewModel.model else { return }
        var params = [String: Any]()
        params["name"] = model.name?.trim()
        params["address"] = model.address
        params["typeId"] = model.typeId.rawValue
        params["lat"] = model.lat
        params["lon"] = model.lon
        params["placeId"] = model.placeId
        params["isDriver"] = false
        let router = VatoAPIRouter.customPath(authToken: "", path: "favorite_place", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<PlaceModel>.self, method: .post, encoding: JSONEncoding.default)
            //        .trackActivity(self.trackProgress)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let res):
                    if res.fail {
                        if let errorMess = res.message {
                            AlertVC.showError(for: self, message: errorMess)
                        }
                    }
                    else {
                        wSelf.needReloadData?()
                        wSelf.dismissViewController()
                    }
                case .failure(let e):
                    AlertVC.showError(for: self, message: e.localizedDescription)
                    print(e.localizedDescription)
                }
        }.disposed(by: disposeBag)
    }
    
    func confirmDeleteFavAddress() {
        AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: Text.deleteThisPlaceConfirm.localizedText, actionButton1: Text.cancel.localizedText, actionButton2: Text.deletePlace.localizedText, handler2:{[weak self] in
            guard let self = self else { return }
            self.deleteFavAddress()
        })
    }
    
    func deleteFavAddress() {
        self.deleteFavPlace()
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.trackProgress)
            .subscribe(onNext: { [weak self](_) in
                self?.needReloadData?()
//                self?.navigationController?.popViewController(animated: true)
                self?.dismissViewController()
                }, onError: { (e) in
                    AlertVC.showError(for: self, message: e.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteFavPlace() -> Observable<Data>{
        guard
            let placeId = self.viewModel.model?.id else { return Observable.empty() }
        
        return FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .timeout(.seconds(7), scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                return Requester.request(using: VatoAPIRouter.deleteFavPlace(authToken: authToken, placeId: placeId),
                                         method: .delete,
                                         encoding: JSONEncoding.default)
                
            }.map {
                $0.1
                
        }
    }
    
    func updateFavAddress() {
        guard let model = self.viewModel.model else { return }
        let id = model.id ?? 0

        var params = [String: Any]()
        params["name"] = model.name?.trim()
        params["address"] = model.address
        params["typeId"] = model.typeId.rawValue
        params["lat"] = model.lat
        params["lon"] = model.lon
        params["placeId"] = model.placeId
        params["isDriver"] = false
        let router = VatoAPIRouter.customPath(authToken: "", path: "favorite_place/\(id)", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<PlaceModel>.self, method: .put, encoding: JSONEncoding.default)
//        .trackActivity(self.trackProgress)
        .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let res):
                    if res.fail {
                        if let errorMess = res.message {
                            AlertVC.showError(for: self, message: errorMess)
                        }
                    }
                    else {
                        wSelf.needReloadData?()
                        wSelf.navigationController?.popViewController(animated: true)
                    }
                case .failure(let e):
                    AlertVC.showError(for: self, message: e.localizedDescription)
                    print(e.localizedDescription)
                }
        }.disposed(by: disposeBag)
    }
    
    func fillData() {
        self.nameTextField.text = self.viewModel.model?.name
        self.nameTextField.isEnabled = self.viewModel.isAllowEditName()
        if let address = self.viewModel.getAddress() {
            self.addressLabel.text = address
            self.addressLabel.textColor = UIColor.black
        } else {
            self.addressLabel.text = Text.inputAddress.localizedText
            self.addressLabel.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 0.38)
        }
        self.checkEnableButtonConfirm()
    }
    
    func checkEnableButtonConfirm() {
        if let address = self.viewModel.model?.address,
            address.count > 0,
            let name = self.viewModel.model?.name?.trim(),
            name.count > 0 {
            self.saveAddressButton.isEnabled = true
            self.saveAddressButton.backgroundColor = Color.orange
            return
        }
        self.saveAddressButton.isEnabled = false
        self.saveAddressButton.backgroundColor = UIColor.lightGray
    }
    
    func dismissViewController() {
        self.modeSubject.take(1).subscribe(onNext: {[weak self] mode in
            guard let self = self else { return }
            if mode == .quickCreate {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - Selector
    
    @objc func didTouchAdd(sender:UIButton) {
        
        let vc = SearchPlaceViewController(viewModel: self.viewModel.generateSearchPlaceVM())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UpdatePlaceViewController: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return self.viewButtons
    }
}
class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 9, left: 12, bottom: 9 , right: 0)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UpdatePlaceViewController: UpdatePlaceRoutingListener {
    func getModel(model: AddressProtocol) {
        self.viewModel.model?.address = model.subLocality
        self.viewModel.model?.lat = String(model.coordinate.latitude)
        self.viewModel.model?.lon = String(model.coordinate.longitude)
        self.viewModel.model?.placeId = model.placeId
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func dismiss() {
        self.dismissViewController()
    }
    
}





