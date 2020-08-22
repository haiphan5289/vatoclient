//
//  Ultils.swift
//  FaceCar
//
//  Created by Dung Vu on 9/21/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation
import FwiCore
import RIBs
import RxCocoa
import RxSwift
import Kingfisher
import SDWebImage
import FwiCoreRX
import KeyPathKit
import SnapKit
import Atributika
import MobileCoreServices

// MARK: Helper
protocol LoadXibProtocol {}
extension LoadXibProtocol where Self: UIView {
    static func loadXib() -> Self {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard let view = UINib(nibName: name, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("error xib \(name)")
        }
        return view
    }
}
extension UIView: LoadXibProtocol {}
extension UIViewController {
    public static var name: String {
        return "\(self)"
    }
}

enum SeperatorPositon {
    case top
    case bottom
    case right
    case left
    
}
extension UIView {
    static var nib: UINib? {
        let name = "\(self)"
        return UINib(nibName: name, bundle: nil)
    }
    
    @discardableResult
    func addSeperator(with edges: UIEdgeInsets = .zero, position: SeperatorPositon = .bottom) -> UIView {
        let s = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
        
        switch position {
        case .top:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.height.equalTo(0.5)
                    make.left.equalTo(edges.left)
                    make.right.equalTo(-edges.right).priority(.low)
                    make.top.equalToSuperview()
                })
            }
        case .bottom:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.height.equalTo(0.5)
                    make.left.equalTo(edges.left)
                    make.right.equalTo(-edges.right).priority(.low)
                    make.bottom.equalTo(-edges.bottom)
                })
            }
        case .right:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(0.5)
                    make.top.bottom.equalToSuperview()
                    make.right.equalTo(-edges.right)
                })
            }
        case .left:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(0.5)
                    make.top.bottom.equalToSuperview()
                    make.left.equalTo(edges.left)
                })
            }
        }
        return s
    }
}

extension CLLocation {
    static var zero = CLLocation(latitude: 0, longitude: 0)
}

extension CLLocationCoordinate2D {
    var value: String {
        return "\(self.latitude),\(self.longitude)"
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    func distance(other: CLLocationCoordinate2D) -> Double {
        let c1 = CLLocation(latitude: latitude, longitude: longitude)
        let c2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let result = c1.distance(from: c2).rounded(.awayFromZero)
        return abs(result)
    }
}

extension Dictionary {
    func value<E>(for key: Key, defaultValue: @autoclosure () -> E) -> E {
        guard let result = self[key] as? E else {
            return defaultValue()
        }
        return result
    }
    
    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    subscript(from keys: Key...) -> [Value] {
        var result = [Value]()
        keys.forEach { (k) in
            guard let v = self[k] else {
                return
            }
            result.append(v)
        }
        return result
    }
    
    subscript(optional key: Key?) -> Value? {
        set {
            guard let key = key else { return }
            self[key] = newValue
        }
        
        get {
            guard let key = key else { return nil }
            return self[key]
        }
    }
    
    static func +=(lhs: inout Self, rhs: Self?) {
        rhs?.forEach({ (element) in
            lhs[element.key] = element.value
        })
    }
}

extension Array {
    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Decodable {
    static func toModel(from data: Data, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        let decoder = JSONDecoder()
        let d = data
        // custom
        block?(decoder)
        do {
            let result = try decoder.decode(self, from: d)
            return result
        } catch let err as NSError {
            debugPrint(err)
            throw err
        }
    }

    static func toModel(from json: JSON?, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        guard let data = try json?.toData() else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: "Not available data!!!"])
        }
        return try self.toModel(from: data, block: block)
    }
}

typealias JSON = [String: Any]
extension Data {
    var json: JSON? {
        let result = try? JSONSerialization.jsonObject(with: self, options: [])
        return result as? JSON
    }
}

infix operator >>>: Display
precedencegroup Display {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: AdditionPrecedence
}

@discardableResult
func >>> <E: AnyObject>(lhs: E, block: (E) -> Void) -> E {
    block(lhs)
    return lhs
}

@discardableResult
func >>> <E: AnyObject>(lhs: E?, block: (E?) -> Void) -> E? {
    block(lhs)
    return lhs
}

func >>> <E, F>(lhs: E, rhs: F) -> E where E: UIView, F: UIView {
    rhs.addSubview(lhs)
    return lhs
}

func >>> <E, F>(lhs: E, rhs: F?) -> E where E: UIView, F: UIView {
    rhs?.addSubview(lhs)
    return lhs
}

func >>> (rhs: FireBaseTable, lhs: FireBaseTable) -> NodeTable {
    let newPath = "\(rhs.name)" + "/" + "\(lhs.name)"
    return NodeTable(currentTable: lhs, path: newPath)
}

func >>> (rhs: NodeTable, lhs: FireBaseTable) -> NodeTable {
    let newPath = "\(rhs.path)" + "/" + "\(lhs.name)"
    return NodeTable(currentTable: lhs, path: newPath)
}

struct NodeTable {
    let currentTable: FireBaseTable
    let path: String
}

@objc
extension NSNumber {
    static let formatCurrency = format()
    
    private static func format() -> NumberFormatter {
        let format = NumberFormatter()
        format.locale = Locale(identifier: "vi_VN")
        format.numberStyle = .currency
        format.currencyGroupingSeparator = ","
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 0
        format.positiveFormat = "#,###\u{00a4}"
        
        return format
    }
    
    func money() -> String? {
       return NSNumber.formatCurrency.string(from: self)
    }
}

extension Numeric {
    
    
    var currency: String {
        return (self as? NSNumber)?.money() ?? ""//.currency(withISO3: "VND", placeSymbolFront: false) ?? ""
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let customDateFireBase = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let time = try container.decode(TimeInterval.self)
        let date = Date(timeIntervalSince1970: time / 1000)

        return date
    }
}
// MARK: - Image
extension UIImage {
    static func image(from color: UIColor, with size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(targetSize: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let sizeImg = size
        let ratio = max(targetSize.width / sizeImg.width, targetSize.height / sizeImg.height)
        let rect = CGRect(origin: .zero, size: sizeImg * ratio)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let result = render.image { _ in
            self.draw(in: rect)
        }
        return result
    }
    
    func compressJPG(quality: CGFloat) -> Data {
        let rect = CGRect(origin: .zero, size: size)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let result = render.jpegData(withCompressionQuality: quality) { (_) in
            self.draw(in: rect)
        }
        return result
    }
    
    func compressPNG() -> Data {
        let rect = CGRect(origin: .zero, size: size)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let result = render.pngData { (_) in
            self.draw(in: rect)
        }
        return result
    }
}

extension UIImage {
    static func createImagePDF(from data: Data) -> UIImage? {
        let pdfData = data as CFData
        guard let provider: CGDataProvider = CGDataProvider(data: pdfData) else {return nil}
        guard let pdfDoc: CGPDFDocument = CGPDFDocument(provider) else {return nil}
        guard let pdfPage: CGPDFPage = pdfDoc.page(at: 1) else {return nil}
        let pdfImage = getImage(from: pdfPage)
        return pdfImage
    }
    
    private static func getImage(from pdfPage: CGPDFPage) -> UIImage? {
        var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
        pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
        UIGraphicsBeginImageContextWithOptions(pageRect.size, false, UIScreen.main.scale)
        guard let context:CGContext = UIGraphicsGetCurrentContext()  else {return nil}
        context.saveGState()
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1, y: -1)
        context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect:  pageRect, rotate: 0, preserveAspectRatio: true))
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        let pdfImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pdfImage
    }
    
    static func loadListImage(from pdfFile: String) -> [UIImage] {
        guard let f = Bundle.main.url(forResource: pdfFile, withExtension: "pdf") else {
            return []
        }
        do {
            let data = try Data(contentsOf: f)
            var current: Int = 1
            let pdfData = data as CFData
            guard let provider: CGDataProvider = CGDataProvider(data: pdfData) else { return [] }
            guard let pdfDoc: CGPDFDocument = CGPDFDocument(provider) else { return [] }
            guard let fPage: CGPDFPage = pdfDoc.page(at: current) else { return [] }
            let pages = sequence(first: fPage) { (_) -> CGPDFPage? in
                current += 1
                return pdfDoc.page(at: current)
            }
            let images = pages.compactMap(getImage(from:))
            return images
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    convenience init?(optional name: String?) {
        guard let name = name, !name.isEmpty else {
            return nil
        }
        self.init(named: name)
    }
}

// MARK: - View
extension UIView {
    var edgeSafe: UIEdgeInsets {
        if #available(iOS 11, *) {
            return self.safeAreaInsets
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}


// MARK: Debug Log
func printDebug(_ items: Any..., file: String = #file, line: Int = #line) {
    #if DEBUG
        let p = file.components(separatedBy: "/").last ?? ""
        print("DEBUG \(p), Line: \(line): \(items)")
    #endif
}

func printError(err: Error, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let e = err as NSError
    var message = "\(e.domain) \(e.code)\n  \(e.localizedDescription)\n"
    if e.userInfo.count > 0 {
        message += "  UserInfo:\n"
        e.userInfo.forEach {
            message += "  -> \($0.key): \($0.value)\n"
        }
    }

    let displayName = file.components(separatedBy: "/").last ?? ""
    print("\(displayName) > [\(function) \(line) \(NSDate())]: \(message)")
    #endif
}

// MARK: Try catch
func tryNotThrow<T>(_ block: () throws -> T, default: @autoclosure () -> T) -> T {
    do {
        return try block()
    } catch {
        printDebug(error.localizedDescription)
        return `default`()
    }
}


// MARK: KeyPath
prefix operator ~

prefix func ~ <A, B>(_ keyPath: KeyPath<A, B>) -> (A) -> B {
    return { $0[keyPath: keyPath] }
}

//prefix func ~ <A, B>(_ keyPath: KeyPath<A, B>) -> (A, A) -> Bool where B: Comparable {
//    return { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
//}

//prefix func ~ <A>(_ keyPath: KeyPath<A, Bool>) -> (A) -> Bool {
//    return { $0[keyPath: keyPath] }
//}

struct WritableKeyPathApplicator<Type> {
    private let applicator: (Type, Any) -> Type
    init<ValueType>(_ keyPath: WritableKeyPath<Type, ValueType>) {
        applicator = {
            var instance = $0
            if let value = $1 as? ValueType {
                instance[keyPath: keyPath] = value
            }
            return instance
        }
    }
    func apply(value: Any, to: Type) -> Type {
        return applicator(to, value)
    }
}

func setter<Object: AnyObject, Value>(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void {
    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

func setter<Object: AnyObject, Value>(for object: Object?, keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void {
    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

// MARK : Attribute String
extension String {
    var attribute: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    var url: URL? {
        guard let n = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: n)
    }
    
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from:self)
        return date
    }
    
    static func makeStringWithoutEmpty(from others: String?..., seperator: String) -> String {
        let new = others.compactMap { $0 }.filter(where: \.isEmpty == false).joined(separator: seperator)
        return new
    }
}

enum AttributeStyle {
    case color(c: UIColor)
    case paragraph(p: NSParagraphStyle)
    case font(f: UIFont)
    case strike(v: CGFloat)
    
    var key: NSAttributedString.Key {
        switch self {
        case .color:
            return .foregroundColor
        case .paragraph:
            return .paragraphStyle
        case .font:
            return .font
        case .strike:
            return .strikethroughStyle
        }
    }
    
    var value: Any {
        switch self {
        case .color(let c):
            return c
        case .paragraph(let p):
            return p
        case .font(let f):
            return f
        case .strike(let v):
            return v
        }
    }
}

extension NSAttributedString {
    func add(attribute: AttributeStyle) -> NSAttributedString {
        let text = self.string
        guard !text.isEmpty else {
            return self
        }
        
        let mAttribute = NSMutableAttributedString(attributedString: self)
        let range = NSMakeRange(0, text.count)
        mAttribute.addAttributes([attribute.key : attribute.value], range: range)
        return mAttribute
    }
    
    func add(attributes: [AttributeStyle]) -> NSAttributedString {
        let text = self.string
        guard !text.isEmpty else {
            return self
        }
        
        let mAttribute = NSMutableAttributedString(attributedString: self)
        let range = NSMakeRange(0, text.count)
        
        attributes.forEach {
            mAttribute.addAttributes([$0.key : $0.value], range: range)
        }
        
        return mAttribute
    }
    
    func add(from attribute: NSAttributedString) -> NSAttributedString {
        let text = attribute.string
        guard !text.isEmpty else {
            return self
        }
        
        let mAttribute = NSMutableAttributedString(attributedString: self)
        mAttribute.append(attribute)
        return mAttribute
    }
    
}

func >>> (lhs: NSAttributedString, rhs: AttributeStyle) -> NSAttributedString {
    return lhs.add(attribute: rhs)
}

func >>> (lhs: NSAttributedString?, rhs: AttributeStyle) -> NSAttributedString? {
    return lhs?.add(attribute: rhs)
}

func >>> (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    return lhs.add(from: rhs)
}

// MARK: Date
enum DateIdentifier: String {
    case utc = "UTC"
    case vn = "Asia/Ho_Chi_Minh"
}

extension TimeZone {
    static let utc = TimeZone(identifier: DateIdentifier.utc.rawValue)
}

extension Date {
    private static let formatDateDefault = DateFormatter()
    func string(from format: String = "dd/MM/yyyy") -> String {
        Date.formatDateDefault.dateFormat = format
        let result = Date.formatDateDefault.string(from: self)
        return result
    }
    
    func toGMT(for identifier: DateIdentifier = .utc) -> Date {
            let next = TimeZone(identifier: identifier.rawValue)?.secondsFromGMT() ?? 0
            let current = TimeZone.current.secondsFromGMT()
            let delta = next - current
            return addingTimeInterval(TimeInterval(delta))
        }

        func to24h() -> TimeInterval {
            let calendar = Calendar(identifier: .gregorian)
            let component = calendar.dateComponents([.hour, .minute, .second], from: self)
            let hour = component.hour ?? 0
            let minute = component.minute ?? 0
            let seconds = component.second ?? 0
            return Double(hour) + Double(minute) / 60 + Double(seconds) / 3600
        }
    
    static func date(from str: String?, format: String, identifier: DateIdentifier = .utc) -> Date? {
        guard let str = str, !str.isEmpty else {
            return nil
        }
        precondition(!format.isEmpty, "Format is not empty.")
        let formater = DateFormatter()
        formater.dateFormat = format
        formater.timeZone = TimeZone(identifier: identifier.rawValue)
        let result = formater.date(from: str)
        return result
    }
}

// MARK: Array
extension Array {
    subscript(safe idx: Int) -> Element? {
        guard 0..<self.count ~= idx else {
            return nil
        }
        return self[idx]
    }
    
    
    mutating func addOptional(_ element: Element?) {
        guard let element = element else {
            return
        }
        self.append(element)
    }
    
    func addSequenceOptional(rhs: [Element]?) -> [Element] {
        guard let other = rhs  else {
            return self
        }
        return self + other
    }
    
}

// MARK: Set status
extension UIApplication {
    static func setStatusBar(using type: UIStatusBarStyle) {
        UIApplication.shared.statusBarStyle = type
    }
}

// MARK: Double
extension Double {
    func round(to places: Int) -> Double {
        let space = pow(10.0, Double(places))
        let v = (self * space).rounded() / space
        return v
    }
    
    func roundPrice() -> UInt32 {
        let average: UInt32
        let min = UInt32(self) / 1000
        if Int(self) % 1000 > 0 {
            average = min * 1000 + 1000
        } else {
            average = min * 1000
        }
        return average
    }
    
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func convertToKm() -> String {
        let km = self / 1000
        return "\(km.round(to: 1).cleanValue) km"
    }
}

// MARK: Check jailbroken
@objcMembers
final class ValidateDeviceJailBreak: NSObject {
    private struct Validate {
        struct TestCase {
            enum Path: String, CaseIterable {
                case cydia = "/Applications/Cydia.app"
                case substrate = "/Library/MobileSubstrate/MobileSubstrate.dylib"
                case bash = "/bin/bash"
                case sshd = "/usr/sbin/sshd"
                case apt = "/etc/apt"
                case privateApt = "/private/var/lib/apt/"
            }
            
            struct URL {
                static let package = Foundation.URL(string: "cydia://package/com.example.package")
            }
            
            struct Write {
                static let fName = "/private/JailbreakTest.txt"
            }
        }
        
        
        func jaibreak() -> Bool {
            func runTestCase() -> Bool {
                let fileManager = FileManager.default
                if TestCase.Path.allCases.first(where: { fileManager.fileExists(atPath: $0.rawValue) }) != nil {
                    return true
                }
                
                if let p = TestCase.URL.package, UIApplication.shared.canOpenURL(p) {
                    return true
                }
                
                let stringToWrite = "Jailbreak Test"
                do {
                    try stringToWrite.write(toFile: TestCase.Write.fName, atomically: true, encoding: .utf8)
                    return true
                } catch {
                    return false
                }
            }
            
            #if targetEnvironment(simulator)
                return false
            #else
                return runTestCase()
            #endif
        }
    }
    
    static func isJailBreak() -> Bool {
        return Validate().jaibreak()
    }
}

// MARK: - Safe protocol
protocol SafeAccessProtocol {
    var lock: NSRecursiveLock { get }
}

extension SafeAccessProtocol {
    @discardableResult
    func excute<T>(block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}

// MARK: - Firebase Time

@objcMembers
final class FireBaseTimeHelper:NSObject, SafeAccessProtocol {
    static let `default` = FireBaseTimeHelper()
    private struct Config {
        static let timeUpdate: Int = 15
    }
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private var diposeAble: Disposable?
    private var _currentTime: TimeInterval = 0
    private var _offset: TimeInterval = 0
    private (set) var offset: TimeInterval {
        get {
            return excute { _offset }
        }
        
        set {
            excute { _offset = newValue }
        }
    }
    var currentTime: TimeInterval {
        return self.excute(block: { _currentTime > 0 ? _currentTime : (Date().timeIntervalSince1970 * 1000) })
    }
    
    func startUpdate() {
        diposeAble?.dispose()
        diposeAble = Observable<Int>.interval(.seconds(Config.timeUpdate), scheduler: SerialDispatchQueueScheduler(qos: .background)).startWith(-1).debug("Interval Check").bind { (_) in
            self.requestTime()
        }
    }
    
    private func requestTime() {
        let db = Database.database().reference(withPath: ".info/serverTimeOffset")
        db.observeSingleEvent(of: .value) { (d) in
            let offset = d.value as? Double
            let c = Date().timeIntervalSince1970
            let interval = c * 1000 + (offset ?? 0)
            self.offset = offset.orNil(0)
            self.update(by: interval)
        }
    }
    
    private func update(by time: TimeInterval) {
        self.excute { self._currentTime = time.rounded(.awayFromZero) }
    }
    
    func stopUpdate() {
        diposeAble?.dispose()
        diposeAble = nil
    }
}

// MARK: - weakitify code
protocol Weakifiable: AnyObject {}
extension Weakifiable {
    func weakify(_ code: @escaping (Self) -> Void) -> () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            code(self)
        }
    }
    
    func weakify<T>(_ code: @escaping (T, Self) -> Void) -> (T) -> Void {
        return { [weak self] arg in
            guard let self = self else { return }
            code(arg, self)
        }
    }
}

// MARK: - Controller
extension UIViewController: Weakifiable {}

// MARK: - Image Display
struct ImageProcessorDisplay: ImageProcessor {
    var identifier: String
    let targetSize: CGSize
    
    init(target: CGSize, key: String) {
        targetSize = target
        identifier = "\(key)_\(target.width)_\(target.height)"
    }
    
    func process(item: ImageProcessItem, options _: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        var img: KFCrossPlatformImage?
        switch item {
        case let .data(data):
            img = KFCrossPlatformImage(data: data)
        case let .image(image):
            img = image
        }
        
        guard let i = img else {
            return nil
        }
        
        let sizeImg = i.size
        let ratio = max(targetSize.width / sizeImg.width, targetSize.height / sizeImg.height)
        let rect = CGRect(origin: .zero, size: sizeImg * ratio)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let result = render.image { _ in
            i.draw(in: rect)
        }
        
        return result
    }
}

extension CGSize {
    static func / (lhs: CGSize, value: CGFloat) -> CGSize {
        precondition(value != 0, "Value is not equal 0!!!")
        return CGSize(width: lhs.width / value, height: lhs.height / value)
    }
    
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

protocol ImageDisplayProtocol {
    var imageURL: String? { get }
    var sourceImage: Source? { get }
    var cacheLocal: Bool { get }
}
extension ImageDisplayProtocol {
    var sourceImage: Source? {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            return nil
        }
        
        return .network(url)
    }
}

protocol TaskExcuteProtocol {
    var identifier: String { get }
    func cancel()
}

extension DownloadTask: TaskExcuteProtocol {
    var identifier: String {
        return "DownloadTask"
    }
}

fileprivate final class LoadImageSDCache: TaskExcuteProtocol, Weakifiable {
    private var disposeLoad: Disposable?
    private let session: URLSession
    private (set) var identifier: String = ""

    private weak var imageView: UIImageView?
    init(for imageView: UIImageView?) {
        self.imageView = imageView
        self.session = URLSession.shared
        session.configuration.allowsCellularAccess = true
//        session.configuration.isDiscretionary = true
        if #available(iOS 11, *) {
            session.configuration.waitsForConnectivity = true
        }
    }
    
    private func downloadImage(url: URL, size: CGSize) -> Observable<UIImage> {
        identifier = url.absoluteString
        DispatchQueue.main.async {
            self.imageView?.indicator?.startAnimating()
        }
        let event = Observable<(URL?, String?)?>.create { [unowned session](s) -> Disposable in
                let task = session.downloadTask(with: url) { (location, response, e) in
                    let complete: ((URL?, String?)?) -> () = {
                        s.onNext($0)
                        s.onCompleted()
                    }
                    guard let l = location else {
                        return complete(nil)
                    }
                    
                    let item = l.lastPathComponent
                    guard let new = URL.documentDirectory()?.appendingPathComponent(item) else {
                        return complete(nil)
                    }
                    do {
                        try FileManager.default.copyItem(at: l, to: new)
                        complete((new, response?.suggestedFilename))
                    } catch {
                        #if DEBUG
                            assert(false, error.localizedDescription)
                        #endif
                        complete(nil)
                    }
                }
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
        }.do(onDispose: { [weak self] in
            DispatchQueue.main.async {
                self?.imageView?.indicator?.stopAnimating()
            }
        }).filterNil()
            .flatMap { (r) -> Observable<Data> in
                guard let new = r.0 else { return Observable.empty() }
                return CachedResourceManager.instance.cacheImage(url: url, fileURL: new, suggestName: r.1)
        }.delay(.milliseconds(200), scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (d) -> Observable<UIImage?> in
                return CachedResourceManager.instance.loadImage(url: url, size: size)
            }.filterNil()

        return event
    }
    
    func load(key: String, size: CGSize) {
        guard let url = URL(string: key) else { return }
        let loadImage = CachedResourceManager.instance.loadImage(url: url, size: size).flatMap { [weak self](r) -> Observable<UIImage> in
            guard let wSelf = self else { return Observable.empty() }
            if let i = r {
                return Observable.just(i)
            } else {
                return wSelf.downloadImage(url: url, size: size)
            }
        }
        
        disposeLoad = loadImage.map { $0.copy() as? UIImage }.bind(onNext: { [weak self](image) in
            DispatchQueue.main.async {
                self?.imageView?.image = image
            }
        })
    }
    
    func cancel() {
        disposeLoad?.dispose()
    }
    
    deinit {
        cancel()
    }
}

fileprivate struct TaskKeyLoad {
    static var key = "TaskKeyLoad"
    static var loading = "TaskLoading"
}

extension UIImageView {
    static let cacheOriginal = ImageCache(name: "com.vato.cacheOriginal")
    private var task: TaskExcuteProtocol? {
        get {
            return objc_getAssociatedObject(self, &TaskKeyLoad.key) as? TaskExcuteProtocol
        }
        
        set {
            objc_setAssociatedObject(self, &TaskKeyLoad.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func createIndicator() -> UIActivityIndicatorView {
        let i: UIActivityIndicatorView
        if #available(iOS 13, *) {
            i = UIActivityIndicatorView(style: .medium)
        } else {
            i = UIActivityIndicatorView(style: .gray)
        }
        i.hidesWhenStopped = true
        self.addSubview(i)
        defer {
            i.snp.makeConstraints { (make) in
                make.center.equalToSuperview().priority(.high)
            }
        }
        return i
    }
    
    fileprivate var indicator: UIActivityIndicatorView? {
        get {
            if let indicator = objc_getAssociatedObject(self, &TaskKeyLoad.loading) as? UIActivityIndicatorView {
                return indicator
            } else {
                let new = createIndicator()
                objc_setAssociatedObject(self, &TaskKeyLoad.loading, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return new
            }
        }
        
        set {
            objc_setAssociatedObject(self, &TaskKeyLoad.loading, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static let imageDefault = UIImage(named: "ic_placeholder_product")
    @discardableResult
    func setImage(from source: ImageDisplayProtocol?, placeholder: UIImage? = nil, size: CGSize? = nil) -> TaskExcuteProtocol? {
        let placeholder = placeholder ?? UIImageView.imageDefault
        guard let s = source else {
            return nil
        }
        let mSize = size ?? bounds.size
        precondition(mSize != .zero, "Recheck size")
        let key = source?.sourceImage?.url?.lastPathComponent ?? "com.vato.image_\(mSize)"
        let processor = ImageProcessorDisplay(target: mSize, key: key)
        
        if UIImageView.cacheOriginal.isCached(forKey: processor.identifier) {
            UIImageView.cacheOriginal.retrieveImage(forKey: processor.identifier) { [weak self](result) in
                switch result {
                case .success(let r):
                    self?.image = r.image
                case .failure:
                    self?.image = placeholder
                }
            }
            return nil
        }
        
        if case .activity = kf.indicatorType  {
        } else {
            kf.indicatorType = .activity
        }
        let options: KingfisherOptionsInfo = [.memoryCacheExpiration(.never), .diskCacheExpiration(.never) , .processor(processor), .callbackQueue(CallbackQueue.dispatch(.global(qos: .background)))]
        let task = kf.setImage(with: s.sourceImage, placeholder: placeholder, options: options) { result in
            switch result {
            case .success(let r):
                UIImageView.cacheOriginal.store(r.image, forKey: processor.identifier)
            case .failure:
                break
            }
        }
        return task
    }
}

// MARK: - Loading
extension ActivityTrackingProtocol {
    var loading: Observable<Bool> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: - Auto create url
extension String: ImageDisplayProtocol {
    var cacheLocal: Bool { return true }
    var imageURL: String? {
        return self
    }
}

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

func mainAsync<T>(block: ((T) -> ())?) -> (T) -> () {
    return { value in
        DispatchQueue.main.async {
            block?(value)
        }
    }
}

// MARK: - Color
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
// MARK: -- CLLocationCoordinate2D
extension CLLocationCoordinate2D {
    func bear(to other: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        
        let lat2 = other.latitude * .pi / 180
        let lon2 = other.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing * 180 / .pi
    }
    
    static func generateWayToCoordinate(from path: GMSPath,
                                         start: CLLocationCoordinate2D,
                                         end: CLLocationCoordinate2D) -> Observable<(p1: String, p2: String)>
    {
        guard path.count() > 1 else { return Observable.empty() }
        return Observable.create { (r) -> Disposable in
            
            let s = path.coordinate(at: 0)
            let e = path.coordinate(at: path.count() - 1)
            DispatchQueue(label: "com.vato.polyline").async {
                let p1 = Polyline(coordinates: [s, start]).encodedPolyline
                let p2 = Polyline(coordinates: [e, end]).encodedPolyline
                r.onNext((p1, p2))
                r.onCompleted()
            }
            return Disposables.create()
        }.observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: -- Degree marker
protocol MapMarkerProtocol: AnyObject {
    var rotation: CLLocationDegrees { get set }
    var position: CLLocationCoordinate2D { get set }
}

extension MapMarkerProtocol {
     func updateMarker(from coordinate: CLLocationCoordinate2D) {
        let current = self.position
        let rotation = self.rotation
        let calBearing = current.bear(to: coordinate)
        var newAngle = calBearing
        if calBearing < 0 {
            newAngle += 360
        }
        let deltaAngle = fabs(newAngle - rotation)
        var duration: TimeInterval = 5
        if (calBearing != 0 && deltaAngle > 70) {
            duration = 1
        }
        
        if duration == 1.0 {
            self.position = coordinate
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut], animations: { [unowned self] in
            if (duration != 1.0) {
                self.position = coordinate
            }
            
            if (calBearing != 0) {
                self.rotation = calBearing
            }
        }, completion: nil)
    }
}

extension GMSMarker: MapMarkerProtocol {}

// MARK: - Application
extension UIApplication {
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        guard let controller = controller else {
            return nil
        }
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    private static func showAlertConfirmInstall(appName: String) -> Observable<Bool> {
        return Observable.create { (s) -> Disposable in
            let topVC = self.topViewController()
            let message = String(format: FwiLocale.localized("Bạn chưa cài đặt ứng dụng <b>%@</b> . Bạn có muốn cài đặt không?"), appName)
            let b = Atributika.Style("b").font(UIFont.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1))
            let p = NSMutableParagraphStyle()
            p.alignment = .center
            let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)).font(UIFont.systemFont(ofSize: 15, weight: .regular)).paragraphStyle(p)
            let att = message.style(tags: b).styleAll(all).attributedString
            let styleMessage = AlertAttributeTextValue(attributedText: att)
            
            let buttonCancel = AlertAction(style: .newCancel,
                                       title: FwiLocale.localized("Bỏ qua")) {
                                        s.onNext(false)
                                        s.onCompleted()
            }
            
            let buttonOK = AlertAction(style: .newDefault,
                                       title: FwiLocale.localized("Đồng ý")) {
                                        s.onNext(true)
                                        s.onCompleted()
            }
            
            AlertCustomVC.show(on: topVC, option: [.title, .message],
                               arguments: [.title: AlertLabelValue(text: FwiLocale.localized("Thông báo"),
                                                                   style: .titleDefault),
                                           .message: styleMessage],
                               buttons: [buttonCancel, buttonOK], orderType: .horizontal)
            
            
            return Disposables.create()
        }
    }
    
    /// Open other app , by check and show alert if not installed
    /// - Parameters:
    ///   - name: app name. Ex: Vato Merchant
    ///   - scheme: scheme to query app
    ///   - id: id app on appstore
    /// - Returns: event complete
    static func openApp(name: String, scheme: String, id: String) -> Observable<Void> {
        guard let otherApp = URL(string: "\(scheme)://app") else {
            return Observable.empty()
        }
        
        return Observable<Void>.create { (s) -> Disposable in
            var dispose: Disposable?
            if UIApplication.shared.canOpenURL(otherApp) {
                UIApplication.shared.open(otherApp, options: [:]) { (_) in
                    s.onCompleted()
                }
            } else {
                dispose = self.showAlertConfirmInstall(appName: name).bind (onNext:{ (result) in
                    if result, let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id\(id)?mt=8") {
                        UIApplication.shared.open(url, options: [:]) { (_) in
                            s.onCompleted()
                        }
                    } else {
                        s.onCompleted()
                    }
                })
            }
            return Disposables.create {
                dispose?.dispose()
            }
        }
        
    }
}

// MARK: - Empty Protocol
protocol EmptyProtocol {
    var isEmpty: Bool { get }
}

extension EmptyProtocol {
    func orEmpty(_ default: @autoclosure () -> Self) -> Self {
        guard !isEmpty else {
            return `default`()
        }
        return self
    }
}
extension String: EmptyProtocol {}
extension Error {
    static func error(message: String, code: Int? = nil) -> Error {
        let e = NSError(domain: NSURLErrorDomain, code: code.orNil(NSURLErrorUnknown), userInfo: [NSLocalizedDescriptionKey: message])
        return e
    }
}

// MARK: - Queue
extension DispatchQueue {
    private static let homeIgnoreCache = DispatchSpecificKey<Bool>()
    private static let checkLatePayment = DispatchSpecificKey<Bool>()
    private static let homeLoadCache = DispatchSpecificKey<Bool>()
    
    static var ignoreCache: Bool {
        get {
           return DispatchQueue.main.getSpecific(key: homeIgnoreCache).orNil(true)
        }
        
        set {
            DispatchQueue.main.setSpecific(key: homeIgnoreCache, value: newValue)
        }
    }
    
    static var needCheckLatePayment: Bool {
        get {
           return DispatchQueue.main.getSpecific(key: checkLatePayment).orNil(true)
        }
        
        set {
            DispatchQueue.main.setSpecific(key: checkLatePayment, value: newValue)
        }
    }
    
    static var loadCacheHome: Bool {
        get {
           return DispatchQueue.main.getSpecific(key: homeLoadCache).orNil(false)
        }
        
        set {
            DispatchQueue.main.setSpecific(key: homeLoadCache, value: newValue)
        }
    }
}

// MARK: -- File
enum FileMediaType: Int {
    case image
    case movie
    case text
    case unknown
    
    static func identifyMedia(from file: URL?) -> FileMediaType {
        guard let file = file else {
            return .unknown
        }
        let ext = file.pathExtension
        guard !ext.isEmpty else {
            return .unknown
        }
        let fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        guard let value = fileUTI?.takeUnretainedValue() else { return .unknown }
        if UTTypeConformsTo(value, kUTTypeImage) {
            return .image
        }
        
        if UTTypeConformsTo(value, kUTTypeMovie) {
            return .movie
        }
        
        if UTTypeConformsTo(value, kUTTypeText) {
            return .text
        }
        
        return .unknown
    }
}




