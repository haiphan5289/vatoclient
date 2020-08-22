//  File name   : BookingConfirmPromotionInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Alamofire
import RIBs
import RxSwift
import VatoNetwork

protocol BookingConfirmPromotionRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BookingConfirmPromotionPresentable: Presentable {
    var listener: BookingConfirmPromotionPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BookingConfirmPromotionListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func closeInputPromotion()
    func update(model: PromotionModel?)
}

final class BookingConfirmPromotionInteractor: PresentableInteractor<BookingConfirmPromotionPresentable>, BookingConfirmPromotionInteractable, BookingConfirmPromotionPresentableListener {
    weak var router: BookingConfirmPromotionRouting?
    weak var listener: BookingConfirmPromotionListener?

    private(set) var authenticatedStream: AuthenticatedStream
    private(set) var priceStream: PriceStream
    private(set) var promotionStream: MutablePromotion
    private var booking: Booking?
    private var price: BookingConfirmPrice?
    private var current: PromotionModel?
    private lazy var disposeBag = DisposeBag()

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: BookingConfirmPromotionPresentable, authenticatedStream: AuthenticatedStream, priceStream: PriceStream, promotionStream: MutablePromotion) {
        self.authenticatedStream = authenticatedStream
        self.priceStream = priceStream
        self.promotionStream = promotionStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        prepareData()
    }

    private func prepareData() {
        priceStream.booking.bind { [weak self] b in
            self?.booking = b
        }.disposed(by: disposeBag)

        priceStream.price.bind { [weak self] p in
            self?.price = p
        }.disposed(by: disposeBag)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func closeInputPromotion() {
        listener?.closeInputPromotion()
    }

    func update(model: PromotionModel?) {
        self.listener?.update(model: model)
    }

    func checkPromotion(from code: String?) -> Observable<PromotionModel> {
        guard let code = code else {
            return Observable.empty()
        }

        return requestPromotionData(from: code).map { [weak self] data in
            let model = PromotionModel(with: code)
            model.data = data
            try self?.calculate(for: model)
            return model
        }
    }

    private func calculate(for model: PromotionModel) throws {
        fatalError("Please Implement")
//        guard let b = self.booking, let p = self.price else {
//            throw PromotionError.notEnoughInformation
//        }
//        let s = model.service?.service.id ?? .none
//        try model.calculateDiscount(from: b, paymentType: self.priceStream.methodPayment, price: p)
    }

    private func requestPromotionData(from code: String) -> Observable<PromotionData> {
        return authenticatedStream.firebaseAuthToken.flatMap { key -> Observable<(HTTPURLResponse, PromotionData)> in
            Requester.requestDTO(using: VatoAPIRouter.promotion(authToken: key, code: code), method: .post, encoding: JSONEncoding.default, block: { $0.dateDecodingStrategy = .customDateFireBase })
        }.map {
            let data = $0.1
            guard data.status == 200 else {
                throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.message ?? ""])
            }
            return data
        }
    }
}
