//
//  MapVC+PickLocationVC.swift
//  FaceCar
//
//  Created by tony on 9/26/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import SnapKit
import UIKit

extension MapVC: PickLocationViewControllable {
    func generatePickLocationUI(for locationType: LocationType) -> (UIView, UILabel, UIButton, UIButton, UIButton) {
        // address view
        let barView = self.barView
        barView >>> view >>> { $0.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        } }

        // back button
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let backButton = self.backButton
        backButton >>> barView >>> { $0.snp.makeConstraints {
            $0.leading.equalTo(barView).inset(15.0)
            $0.top.equalTo(barView).offset(statusHeight)
            $0.bottom.equalTo(barView)
            $0.width.equalTo(40)
            $0.height.equalTo(50)
        } }

        // address label
        let addressLabel = self.addressLabel
        addressLabel >>> barView >>> { $0.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing)
            $0.centerY.equalTo(backButton)
            $0.trailing.equalToSuperview().inset(15.0)
        } }

        // confirm button
        let confirmButton = self.confirmButton
        if locationType == .origin {
            confirmButton.tintColor = Color.darkGreen
            confirmButton.setTitle(Text.confirm.localizedText, for: .normal)
//            confirmButton.setTitle(Text.confirmPickOriginLocation.localizedText, for: .normal)
        } else {
            confirmButton.tintColor = Color.orange
            confirmButton.setTitle(Text.confirm.localizedText, for: .normal)
//            confirmButton.setTitle(Text.confirmPickDestinationLocation.localizedText, for: .normal)
        }
        confirmButton >>> view >>> { $0.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15.0)
            $0.trailing.equalToSuperview().inset(15.0)
            $0.height.equalTo(48)

            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15.0)
            } else {
                $0.bottom.equalToSuperview().inset(15.0)
            }
        } }

        // current location
        let currentLocationButton = self.currentLocationButton
        currentLocationButton >>> view >>> { $0.snp.makeConstraints {
            $0.trailing.equalTo(confirmButton.snp.trailing)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-15.0)
            $0.size.equalTo(24.0)
        } }

        view.layoutIfNeeded()

        let bottomPadding = UIScreen.main.bounds.height - confirmButton.frame.minY + 15.0
        mapView.padding = UIEdgeInsets(top: barView.frame.maxY, left: 15.0, bottom: bottomPadding, right: 15.0)
        mapView.animate(toZoom: 18.0)

        return (barView, addressLabel, backButton, confirmButton, currentLocationButton)
    }

    private var barView: UIView {
        let view = UIView()
        view.backgroundColor = Color.orange
        return view
    }

    private var addressLabel: UILabel {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)

        return label
    }

    private var backButton: UIButton {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "back-w"), for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }

    private var currentLocationButton: UIButton {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setImage(#imageLiteral(resourceName: "ic_current_location"), for: .normal)
        button.backgroundColor = UIColor.clear
        return button
    }

    private var confirmButton: UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "bg_button_01"), for: .normal)
        button.isEnabled = false
        return button
    }
}
