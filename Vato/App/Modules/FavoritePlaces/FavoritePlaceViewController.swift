//
//  FavoritePlaceViewController.swift
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


class FavoritePlaceViewController: UIViewController, LoadingAnimateProtocol, DisposableProtocol {
    var didSelectModel: ((PlaceModel) -> Void)?
    
    // MARK: - property
    @IBOutlet private weak var tableView: UITableView!
    internal lazy var disposeBag = DisposeBag()
    var authenicate: AuthenticatedStream?
    var viewModel = FavoritePlaceVM()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.viewModel.getData()
        setRX()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private method
    private func setupNavigationBar() {
        self.title = Text.favoriteSaved.localizedText
        
        // left button
        var imageLeftButton = UIImage(named: "back-w")
        imageLeftButton = imageLeftButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeftButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
        // right button
        var imageRightButton = UIImage(named: "add")
        imageRightButton = imageRightButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageRightButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func setRX(){
        let event = PlacesHistoryManager.instance
            .favoritePlaces
            .map { $0.filter ({ $0.isOrigin == false }).map(PlaceModel.init(address:)) }
        
        event.bind { [weak self](list) in
            guard let wSelf = self else { return }
            wSelf.viewModel.listOtherModel.removeAll()
            wSelf.viewModel.listModelFavorite.removeAll()
            list.forEach({ (model) in
                if model.typeId == .Orther {
                    wSelf.viewModel.listOtherModel.append(model)
                } else {
                    wSelf.viewModel.listModelFavorite.append(model)
                }
            })
            wSelf.viewModel.listModelFavorite = PlaceModel.generateModel(listModelBackend: wSelf.viewModel.listModelFavorite)
            DispatchQueue.main.async {
                wSelf.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
        
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(){[weak self] event in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            } .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(){ [weak self] event in
                guard let self = self else { return }
                self.showUpdateCreateViewControler(mode: .create, indexPath: nil)
            }
            .disposed(by: disposeBag)
        
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.tableView.rx.setDataSource(self).disposed(by: disposeBag)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        self.tableView.register(UINib(nibName: "PlaceTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PlaceTableHeaderView")
        
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let me = self else { return }
            
            let model = me.viewModel.getModel(at: indexPath)
            if me.viewModel.isFromFavorite && model?.id != nil,
                let model = me.viewModel.getModel(at: indexPath) {
                me.dismiss(animated: true, completion: {
                    me.didSelectModel?(model)
                })
                return
            }
            
            
            me.showUpdateCreateViewControler(mode: .update, indexPath: indexPath)
            }.disposed(by: disposeBag)
        
        
        showLoading(use: trackProgress.asObservable())

    }
    
    private func showUpdateCreateViewControler(mode: UpdatePlaceMode, indexPath: IndexPath?) {
        let UpdatePlaceVM = self.viewModel.generateUpdateViewModel(indexPath: indexPath)
        let vc = UpdatePlaceViewController(mode: mode, viewModel: UpdatePlaceVM)
        vc.auth = self.authenicate
//        vc.needReloadData = {[weak self] in
//            self?.requestData()
//        }
        vc.needReloadData = FavoritePlaceManager.shared.reload
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
}

extension FavoritePlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberRow(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FavoritePlaceTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavoritePlaceTableViewCell
        if cell == nil {
            cell = FavoritePlaceTableViewCell.newCell(reuseIdentifier: identifier)
        }
        if let model = self.viewModel.getModel(at: indexPath) {
            cell?.displayData(model: model)
            cell?.buttonAction = { (sender) in
                self.showUpdateCreateViewControler(mode: .update, indexPath: indexPath)
            }
        }
        return cell!
    }
}

extension FavoritePlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.getNumberRow(section: section) > 0 {
            return 40
        }
         return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    // MARK - tableview delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.getNumberRow(section: section) == 0 {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PlaceTableHeaderView") as! PlaceTableHeaderView
        headerView.displayWithText(text: self.viewModel.getHeaderText(section: section))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}
