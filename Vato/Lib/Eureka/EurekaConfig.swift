//  File name   : EurekaConfig.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCore
//import libPhoneNumberiOS

struct EurekaConfig {
    static let defaultHeight = { return CGFloat(70.0) }
    static let paddingLeft: CGFloat = 0.0
    
    static let errorColor = #colorLiteral(red: 1, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
    static let primaryColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
    static let separatorColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.1)
    
    static let titleColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
    static let detailColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
    static let disabledTitleColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.1)
    static let disabledDetailColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.1)
    static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    static let detailFont = UIFont.systemFont(ofSize: 16.0)
    
    static let placeholderColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.38)
}

extension ValidationError {
    static let empty = ValidationError(msg: "")
}

struct RulesPhoneNumber {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let rulePhone = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
                return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
            }
            
            do {
                let number = try phoneUtil.parse(v, defaultRegion: "VN")
                let nationalNumber = try phoneUtil.format(number, numberFormat: .NATIONAL).replacingOccurrences(of: " ", with: "")
                
                /* Condition validation: phone number cannot have more than 10 digits */
                if nationalNumber.count > 10 {
                    return ValidationError(msg: Text.invalidPhoneNumberLength.localizedText)
                }
                
                if !phoneUtil.isValidNumber(number) {
                    return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
                }
                return nil
            } catch {
                return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
            }
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: RuleRequired(msg: Text.requiredPhoneNumber.localizedText))
        newRules.add(rule: rulePhone)
        
        return newRules
    }
}

struct RulesPhoneOptionalNumber {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let rulePhone = RuleClosure<Value>.init { (v) -> ValidationError? in
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return nil
            }
            
            guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
                return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
            }
            
            do {
                let number = try phoneUtil.parse(v, defaultRegion: "VN")
                let nationalNumber = try phoneUtil.format(number, numberFormat: .NATIONAL).replacingOccurrences(of: " ", with: "")
                
                /* Condition validation: phone number cannot have more than 10 digits */
                if nationalNumber.count > 10 {
                    return ValidationError(msg: Text.invalidPhoneNumberLength.localizedText)
                }
                
                if !phoneUtil.isValidNumber(number) {
                    return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
                }
                return nil
            } catch {
                return ValidationError(msg: Text.invalidPhoneNumber.localizedText)
            }
        }
        var newRules = RuleSet<Value>()
        newRules.add(rule: rulePhone)
        
        return newRules
    }
}

struct RulesName {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let rulePhone = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return ValidationError(msg: Text.requiredFullname.localizedText)
            }
            
            if trimVal.count < 2  {
                return ValidationError(msg: Text.invalidFullnameLengthMin.localizedText)
            }
            
            if trimVal.count > 30  {
                return ValidationError(msg: Text.invalidFullnameLengthMax.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: RuleRequired(msg: Text.requiredFullname.localizedText))
        newRules.add(rule: rulePhone)
        
        return newRules
    }
}

struct RulesMerchantName {
    typealias Value = MerchantAddNameValue
    
    struct Configs {
        static var ValidateionErrorImageMessage = "Avatar không được để trống"
    }
    
    static func rules() -> RuleSet<Value> {
        let ruleName = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return ValidationError(msg: Text.requiredFullname.localizedText)
            }

            return nil
        }
        
        let ruleImage = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            if v?.image == nil {
                return ValidationError(msg: Configs.ValidateionErrorImageMessage)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: ruleName)
        newRules.add(rule: ruleImage)
        
        return newRules
    }
}


struct RulesEmail {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let ruleEmail = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return ValidationError(msg: Text.invalidEmail.localizedText)
            }
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", pattern)
            if emailPredicate.evaluate(with: trimVal) == false {
                return ValidationError(msg: Text.invalidEmail.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: RuleRequired(msg: Text.invalidEmail.localizedText))
        newRules.add(rule: ruleEmail)
        
        return newRules
    }
}

struct RulesIdentifyCard {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let ruleIdentifyCard = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return ValidationError(msg: Text.invalidIdentityCard.localizedText)
            }
            if trimVal.count < 8 || trimVal.count > 12  {
                return ValidationError(msg: Text.invalidIdentityCard.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: RuleRequired(msg: Text.invalidIdentityCard.localizedText))
        newRules.add(rule: ruleIdentifyCard)
        
        return newRules
    }
}

struct RulesIdentifyCardOptional {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let ruleIdentifyCard = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return nil
            }
            if trimVal.count < 8 || trimVal.count > 12  {
                return ValidationError(msg: Text.invalidIdentityCard.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        newRules.add(rule: ruleIdentifyCard)
        
        return newRules
    }
}

struct RulesEmailOptional {
    typealias Value = String
    
    static func rules() -> RuleSet<Value> {
        let ruleEmail = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal == "" {
                return nil
            }
            let pattern = "^.+@.+\\.[a-zA-Z]{2,3}$"
            let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", pattern)
            if emailPredicate.evaluate(with: trimVal) == false {
                return ValidationError(msg: Text.invalidEmail.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        newRules.add(rule: ruleEmail)
        
        return newRules
    }
}

struct RulesWidthdraw {
    typealias Value = Int
    
    static func rules(minValue: Value, maxValue: Value) -> RuleSet<Value> {
        /*
         1. Tài khoản "Số dư khả dụng" - Số tiền có thể rút: Sẽ bao gồm 50,000đ phong toả. Ví dụ: Số dư có thể rút là 2,000,000đ thì chỉ có thể rút 1,950,000đđ.
         
         - Nếu Driver yêu cầu rủt 2,000,000đ thì sẽ thông báo text như sau:
         "Số dư tối thiểu cần giữ lại trong tài khoản là 50,000đ"
         
         2. Thêm text lưu ý trong form Add tài khoản:
         "Lưu ý:
         - Tài khoản ngân hàng chỉ được thêm một lần duy nhất.
         - Nếu có thay đổi thông tin, vui lòng gọi tổng đài 1900 6667 để được hướng dẫn."
         */
        
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: FwiLocale.localized("Số tiền cần rút không được để trống."), id: "Required")
        
        var finalMax = maxValue - 50000
        finalMax = max(finalMax, 0)
        let smallerThan = RuleSmallerOrEqualThan<Value>(max: finalMax, msg: "\(FwiLocale.localized("Số dư tối thiểu trong tài khoản là")) \(50000.currency).", id: "check_max")
        
        let greaterThan = RuleGreaterOrEqualThan<Value>(min: minValue, msg: "\(FwiLocale.localized("Số tiền rút tối thiểu là")) \(minValue.currency).", id: "check_min")
        let ruleDiv = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v else {
                return nil
            }
            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "\(FwiLocale.localized("Số tiền rút phải là bội số của")) \(div.currency)")
        }
        newRules.add(rule: required)
        newRules.add(rule: smallerThan)
        newRules.add(rule: greaterThan)
        newRules.add(rule: ruleDiv)
        return newRules
    }
}




struct RulesTopUp {
    typealias Value = Int
    static func rules(minValue: Value, maxValue: Value) -> RuleSet<Value> {
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: FwiLocale.localized("Số tiền cần nạp không được để trống."), id: "Required")
        
        let smallerThan = checkMaxRule(maxValue: maxValue)
        let greaterThan = checkMinRule(minValue: minValue)
        let ruleDiv = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v, v > 0 else {
                return nil
            }
            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "\(FwiLocale.localized("Số tiền nạp phải là bội số của")) \(div.currency)")
        }
        newRules.add(rule: required)
        newRules.add(rule: smallerThan)
        newRules.add(rule: greaterThan)
        newRules.add(rule: ruleDiv)
        return newRules
    }
    
    static func checkMaxRule(maxValue: Value) -> RuleSmallerOrEqualThan<Value> {
        return RuleSmallerOrEqualThan<Value>(max: maxValue, msg: "\(FwiLocale.localized("Số tiền nạp phải nhỏ hơn")) \(maxValue.currency).", id: "check_max")
    }
     
    static func checkMinRule(minValue: Value) -> RuleGreaterOrEqualThan<Value> {
        return RuleGreaterOrEqualThan<Value>(min: minValue, msg: "\(FwiLocale.localized("Giới hạn số tiền tối thiểu là")) \(minValue.currency).", id: "check_min")
    }
    
    
}


struct RulesLink {
    typealias Value = String
    static func rules() -> RuleSet<Value> {
        
        let ruleURL = RuleClosure<Value>.init { (v) -> ValidationError? in
            let pattern = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
            let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[pattern])
            if predicate.evaluate(with: v) == false {
                return ValidationError(msg: "Error link")
            }
            return nil
            
        }
    
        var newRules = RuleSet<Value>()
        newRules.add(rule: RuleRequired(msg: "Liên kết không được để trống"))
        newRules.add(rule: ruleURL)
        
        return newRules
    }
}

struct RulesMerchantDoubleImage {
    typealias Value = MerchantDoubleImage
    
    static func rules() -> RuleSet<Value> {
        let ruleEmail = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            guard let v = v else {
                return ValidationError(msg: Text.fieldRequired.localizedText)
            }
            
            if v.left == nil || v.right == nil {
                return ValidationError(msg: Text.fieldRequired.localizedText)
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: ruleEmail)
        
        return newRules
    }
}

struct RulesMerchantMultipleImage {
    typealias Value = [UploadedImage]
    
    static func rules() -> RuleSet<Value> {
        let ruleEmail = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            guard let v = v else {
                return ValidationError(msg: Text.fieldRequired.localizedText)
            }
            
            if v.count == 0 {
                return ValidationError(msg: Text.fieldRequired.localizedText)
                
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        
        newRules.add(rule: ruleEmail)
        
        return newRules
    }
}


struct RulesTitle {
    typealias Value = String
    
    static func rules(minimumCharacter: UInt) -> RuleSet<Value> {
        let ruleTitle = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal.count < minimumCharacter {
                return ValidationError(msg: "Nhập title")
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        newRules.add(rule: ruleTitle)
        
        return newRules
    }
}


struct RulesMaximumPrice {
    typealias Value = String
    static func rules(maximumValue: Int) -> RuleSet<Value> {
        var rule = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v else {
                return ValidationError(msg: Text.fieldRequired.localizedText)
            }
            
            guard let value = Int(v) else {
                return ValidationError(msg: Text.wrongFormat.localizedText)

            }
            
            if value <= maximumValue {
                return nil
            }
            
            return ValidationError(msg: Text.amountExceed.localizedText + maximumValue.currency)
        }
        
        rule.id = "max_rule"
        var newRules = RuleSet<Value>()
        newRules.add(rule: rule)
        return newRules
    }
}
 

