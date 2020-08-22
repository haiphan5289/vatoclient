//  File name   : MapVCComponent+SearchLocation.swift
//
//  Author      : Vato
//  Created date: 9/28/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import SnapKit

extension MapVC: SearchLocationViewControllable {
    func bind(searchLocationView: SearchLocationView) {
        view.addSubview(searchLocationView)

        searchLocationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }

    func animateFullscreen(for searchLocationView: SearchLocationView, completion: @escaping (Bool) -> Void) {
        searchLocationView.topImageView.transform = CGAffineTransform(translationX: 0, y: -searchLocationView.topImageView.frame.height)
        searchLocationView.bottomImageView.alpha = 0.0
        searchLocationView.backButton.alpha = 0.0

        let minX = searchLocationView.locationInputView.frame.minY
        let height = searchLocationView.locationInputView.frame.height
        searchLocationView.locationInputView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - minX - height - 15.0)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            searchLocationView.topImageView.transform = CGAffineTransform.identity
            searchLocationView.bottomImageView.alpha = 1.0
            searchLocationView.backButton.alpha = 1.0

            searchLocationView.locationInputView.transform = CGAffineTransform.identity
        }, completion: { isFinished in
            completion(isFinished)
        })
    }

    func animateMinimize(for searchLocationView: SearchLocationView, completion: @escaping (Bool) -> Void) {
        let minX = searchLocationView.locationInputView.frame.minY
        let height = searchLocationView.locationInputView.frame.height

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            searchLocationView.bottomImageView.alpha = 0.0
            searchLocationView.backButton.alpha = 0.0
            searchLocationView.topImageView.transform = CGAffineTransform(translationX: 0, y: -searchLocationView.topImageView.frame.height)
            searchLocationView.locationInputView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - minX - height - 15.0)
        }, completion: { isFinished in
            completion(isFinished)
        })
    }
}
