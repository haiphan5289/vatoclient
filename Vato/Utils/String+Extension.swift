//  File name   : String+Extension.swift
//
//  Author      : Dung Vu
//  Created date: 1/17/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

extension String {
    subscript(range: ClosedRange<Int>) -> String {
        let range = NSMakeRange(range.lowerBound, range.upperBound - range.lowerBound)
        let r = (self as NSString).substring(with: range)
        return r
    }
    
    static func format(number n: UInt32, base: UInt32) -> String {
        struct Alphabet {
            static let string = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        let s = Alphabet.string
        precondition(base < s.count, "Not enough characters")
        let substring = s[0...Int(base)]
        return self.format(number: n, stringAlphabet: substring)
    }
    
    fileprivate static func format(number n: UInt32, stringAlphabet: String) -> String {
        let lenght = UInt32(stringAlphabet.count)
        precondition(lenght > 0, "Recheck")
        
        let result: String
        if n < lenght {
            let idx = Int(n)
            result = stringAlphabet[idx...idx + 1]
        } else {
            let first = self.format(number: n / lenght, stringAlphabet: stringAlphabet)
            let idx = Int(n % lenght)
            let second = stringAlphabet[idx...idx + 1]
            result = String(format: "%@%@", first, second)
        }
        return result
    }
}

// Calculate hash
extension String {
    var asciiArray: [Int32] {
        return unicodeScalars.filter { $0.isASCII }.map { Int32($0.value) }
    }
    func javaHash() -> Int32 {
        let codes = asciiArray
        let result = codes.reduce(0) { (result, next) -> Int32 in
            let r = result.multipliedReportingOverflow(by: 31)
            let f = r.partialValue.addingReportingOverflow(next)
            return f.partialValue
        }
        return abs(result)
    }
}

// generate QR Code
extension String {
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    // only for second
    func times() -> Int {
        let arrTime = self.components(separatedBy: ":")
        var list = arrTime.compactMap ({ Int($0) })
        list.reverse()
        
        var result = 0
        list.enumerated().forEach { (offset, element) in
            if offset == 0 {
                result += element
            } else {
                result += (element * 60 * offset)
            }
        }
      return result
    }
}
