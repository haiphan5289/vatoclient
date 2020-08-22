//  File name   : DeliveryDefine.swift
//
//  Author      : Dung Vu
//  Created date: 11/20/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

enum DeliveryDisplayType: Int, CustomStringConvertible, DestinationDisplayProtocol {
    case sender
    case receiver
    
    var title: String {
        switch self {
        case .sender:
            return Text.deliverySender.localizedText
        case .receiver:
            return Text.deliveryReceiver.localizedText
        }
    }
    
    var description: String {
        switch self {
        case .sender:
            return Text.deliveryInputSender.localizedText
        case .receiver:
            return Text.deliveryInputReceiver.localizedText
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .sender:
            return UIImage(named: "ic_origin")
        case .receiver:
            return UIImage(named: "ic_destination")
        }
    }
    
    var placholderAddress: String {
        switch self {
        case .sender:
            return Text.deliveryInputAdressSenderPlaceholder.localizedText
        case .receiver:
            return Text.deliveryInputAdressReceiverPlaceholder.localizedText
        }
    }
    
    var placholderName: String {
        switch self {
        case .sender:
            return Text.deliveryInputNameSenderPlaceholder.localizedText
        case .receiver:
            return Text.deliveryInputNameReceiverPlaceholder.localizedText
        }
    }
    
    var placholderPhone: String {
        switch self {
        case .sender:
            return Text.deliveryInputPhoneSenderPlaceholder.localizedText
        case .receiver:
            return Text.deliveryInputPhoneReceiverPlaceholder.localizedText
        }
    }
    
    var titleAddress: String {
        switch self {
        case .sender:
            return Text.deliveryTitleAdressSender.localizedText
        case .receiver:
            return Text.deliveryTitleAdressReceiver.localizedText
        }
    }
    
    var originalDestination: AddressProtocol? {
        switch self {
        case .receiver:
            return nil
        case .sender:
            return nil
        }
    }
}
