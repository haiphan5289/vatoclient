//  File name   : MapVCComponent+Home.swift
//
//  Author      : Vato
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import SnapKit
import UIKit
import FwiCore

extension MapVC: HomeViewControllable {
    func bind(menuButton: UIButton) {
//        let statusHeight = UIApplication.shared.statusBarFrame.height
//
//        menuButton >>> view >>> {
//            $0.roundCorner(32.0 / 2.0)
//            $0.borderWidth = 2.0
//            $0.borderColor = Color.orange.withAlphaComponent(0.8)
//
//            $0.snp.makeConstraints {
//                $0.top.equalTo(statusHeight + 10.0)
//                $0.leading.equalToSuperview().offset(15.0)
//                $0.size.equalTo(32.0)
//            }
//        }
    }

    func bind(homeWalletView: HomeWalletView) {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        homeWalletView >>> view >>> { $0.snp.makeConstraints { make in
            make.top.equalTo(statusHeight + 10.0)
            make.trailing.equalToSuperview().inset(15.0)
            make.height.equalTo(32.0)
        } }
    }

    func bind(quickBookingButton: UIButton, homeView: DestinationPickerView) {
        var edgeSafe = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11, *) {
            edgeSafe = UIApplication.shared.keyWindow?.edgeSafe ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        
        let h: CGFloat = 64 + 64 * 2 + 64 // UIScreen.main.bounds.height < 667 ? 318 : 442

        homeView >>> view >>> { $0.snp.makeConstraints {
            $0.leading.equalToSuperview()
        $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(h + edgeSafe.bottom)
//            $0.height.equalTo(242.0)
        } }

        quickBookingButton >>> view >>> {
            $0.dropShadow()
            $0.snp.makeConstraints {

                $0.leading.equalToSuperview().inset(15.0)
                $0.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-200)
            }
        }

        view.layoutIfNeeded()

        // Define map's bound
//        let paddingBottom = UIScreen.main.bounds.height - quickBookingButton.frame.minY + 10.0
//        let paddingTop = UIApplication.shared.statusBarFrame.height
        mapView.padding = UIEdgeInsets(top: 0, left: 15.0, bottom: h-48, right: 15.0)
    }

    func bind(marker: UIImageView) {
        marker >>> view >>> { $0.snp.makeConstraints { make in
            let padding = mapView.padding

            let availableHeight = UIScreen.main.bounds.height - (padding.bottom + padding.top) - marker.frame.height
            let topMargin = availableHeight / 2.0 + padding.top - 5.0

            make.centerX.equalTo(mapView)
            make.top.equalTo(topMargin)
        } }
    }
    
    func bind(headerView: VatoLocationHeaderView, contentView: UIView) {
        
        var edgeSafe = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11, *) {
            edgeSafe = UIApplication.shared.keyWindow?.edgeSafe ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        let h = headerView.frame.size.height
        
        contentView >>> view >>> { $0.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.greaterThanOrEqualTo(h + edgeSafe.top)
            }
        }
        
        headerView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalTo(edgeSafe.top)
                make.bottom.equalToSuperview()
                
            })
        }
    }

}
