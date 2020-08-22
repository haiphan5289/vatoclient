//  File name   : QuickSupportDetailInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork


protocol QuickSupportDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showImages(images: [URL], currentIndex: Int, stackView: UIStackView)
}

protocol QuickSupportDetailPresentable: Presentable {
    var listener: QuickSupportDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol QuickSupportDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func quickSupportDetailMoveBack()
}

final class QuickSupportDetailInteractor: PresentableInteractor<QuickSupportDetailPresentable> {
    /// Class's public properties.
    weak var router: QuickSupportDetailRouting?
    weak var listener: QuickSupportDetailListener?

    /// Class's constructor.
    init(presenter: QuickSupportDetailPresentable, qsItem: QuickSupportModel) {
        self.qsItem = qsItem
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        if let request = qsItem.request {
            self.mQsItemRequest = request
        }
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var qsItem: QuickSupportModel
    @Replay(queue: MainScheduler.asyncInstance) private var mQsItemRequest: QuickSupportItemRequest
}

// MARK: QuickSupportDetailInteractable's members
extension QuickSupportDetailInteractor: QuickSupportDetailInteractable {
}

// MARK: QuickSupportDetailPresentableListener's members
extension QuickSupportDetailInteractor: QuickSupportDetailPresentableListener {
    
    func showImages(currentIndex: Int, stackView: UIStackView) {
        $mQsItemRequest.take(1).subscribe(onNext: {[weak self] (m) in
            guard let me = self else { return }
            let imagesUrl = m.images?.compactMap{ URL(string: $0) }
            guard let images = imagesUrl,
                images.isEmpty == false else { return }
            me.router?.showImages(images: images, currentIndex: currentIndex, stackView: stackView)
        }).disposeOnDeactivate(interactor: self)
    }
    
    var quickSupportRequest: Observable<QuickSupportItemRequest> {
        return $mQsItemRequest
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        
        var response = QuickSupportDetailResponse()
        response.values = qsItem.response
        if let res = response as? T {
            return Observable.just(res)
        } else {
            return Observable.empty()
        }

    }
    
    func quickSupportDetailMoveBack() {
        self.listener?.quickSupportDetailMoveBack()
    }
    
    func dummyInsertData() -> [QuickSupportItemResponse] {
        if let responses = qsItem.response, let response = responses.first {
            return [response]
        }
        return []
    }
    
}

// MARK: Class's private methods
private extension QuickSupportDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
