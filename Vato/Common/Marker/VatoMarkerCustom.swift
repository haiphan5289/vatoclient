//  File name   : VatoMarkerCustom.swift
//
//  Author      : Dung Vu
//  Created date: 7/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import GoogleMaps
import RxSwift
import RxCocoa

final class VatoMarkerCustom: GMSMarker, Weakifiable {
    private struct Configs {
        static let delta: CGFloat = 65
    }
    
    override var map: GMSMapView? {
        didSet {
            setupRX()
        }
    }
    private weak var customView: UIView?
    private lazy var disposeBag = DisposeBag()
    private var identify: String = ""
    private var animateDuration: TimeInterval = 0.3
    private var ratioShowView: CGFloat = 1.5
    convenience init(use coordinate: CLLocationCoordinate2D,
                     id: String, icon: UIImage?,
                     viewChange: UIView?,
                     animateDuration: TimeInterval = 0.3,
                     ratioShowView: CGFloat = 1.5)
    {
        self.init(position: coordinate)
        self.identify = id
        self.icon = icon
        self.animateDuration = animateDuration
        self.ratioShowView = ratioShowView
        self.customView = viewChange
        self.customView?.alpha = 0
    }
    
    private func updatePosition(at pointMarker: CGPoint?) -> CGAffineTransform {
        guard let pointMarker = pointMarker else {
            return .identity
        }

        let delta = self.customView?.transform.ty ?? 0
        let sContainer = self.customView?.frame.size ?? .zero

        let x1 = pointMarker.x - sContainer.width / 2 + delta
        let x2 = pointMarker.x + sContainer.width / 2 + delta

        let nextTransform: CGAffineTransform
        switch (x1 < 0, x2 > UIScreen.main.bounds.width) {
        case (true, _):
            let next = max(x1, -Configs.delta)
            nextTransform = CGAffineTransform(translationX: -next, y: 0)
        case (_, true):
            let next = min(x2 - UIScreen.main.bounds.width, Configs.delta)
            nextTransform = CGAffineTransform(translationX: -next, y: 0)
        default:
            nextTransform = CGAffineTransform.identity
        }
        return nextTransform
    }
    
    private func setupRX() {
        guard let mapView = map else {
            customView?.removeFromSuperview()
            return
        }
        
        let e1 = mapView.rx.methodInvoked(#selector(UIView.layoutSubviews)).map { _ in }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        let e2 = mapView.rx.locationChanged.startWith(self.position).map { _ in }
        Observable.merge([e1, e2]).bind(onNext: weakify({ wSelf in
            guard let p = wSelf.map?.projection.point(for: wSelf.position),
                let customView = wSelf.customView else { return }
            wSelf.customView?.alpha = 1
            let new = CGPoint(x: p.x, y: p.y - wSelf.ratioShowView * customView.bounds.height)
            let transform = wSelf.updatePosition(at: p)
            UIView.animate(withDuration: wSelf.animateDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut], animations: {
                wSelf.customView?.center = new
                wSelf.customView?.transform = transform
            }, completion: nil)
        })).disposed(by: disposeBag)
    }
}

