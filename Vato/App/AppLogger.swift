 //  File name   : AppLogger.swift
//
//  Author      : Futa Corp
//  Created date: 2/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import CocoaLumberjackSwift
import FwiCore

fileprivate typealias LogContent = (item: Any, className: UnsafePointer<CChar>, line: Int)
fileprivate enum LogType {
    case error(content: LogContent)
    case warning(content: LogContent)
    case info(content: LogContent)
    case debug(content: LogContent)
    case verbose(content: LogContent)
    
    var content: LogContent {
        switch self {
        case .error(let content),
             .warning(let content),
             .info(let content),
             .debug(let content),
             .verbose(let content):
            return content
        }
    }
}

//fileprivate extension FwiLog {
//    static func log(_ type: LogType) {
//        guard AppLogger.Config.write else {
//            return
//        }
//        let content = type.content
//        let cls: String = String(String(cString: content.className).substring(fromIndex: 1))
//
//        switch type {
//        case .error:
//           self.error(content.item, className: cls, line: content.line)
//
//        case .warning:
//            self.warning(content.item, className: cls, line: content.line)
//
//        case .info:
//            self.info(content.item, className: cls, line: content.line)
//
//        case .debug:
//            self.debug(content.item, className: cls, line: content.line)
//
//        case .verbose:
//            self.verbose(content.item, className: cls, line: content.line)
//        }
//    }
//}


@objcMembers
final class AppLogger: NSObject {
    struct Config {
        static let write = false
    }
    
    static func setupConsole() {
//        FwiLog.consoleLog()
    }
    
    static func setupFile() {
//        FwiLog.fileLog()
        #if DEBUG
            guard let fileLogger = DDLog.allLoggers.first(where: { $0.isKind(of: DDFileLogger.self) }) as? DDFileLogger else {
                    return
            }
            let logsDirectory = fileLogger.logFileManager.logsDirectory
            debugPrint(logsDirectory)
        #endif
    }
    
    static func error(_ item: Any, className: UnsafePointer<CChar>, line: Int) {
        let type = LogType.error(content: LogContent(item, className, line))
//        FwiLog.log(type)
    }
    
    static func warning(_ item: Any, className: UnsafePointer<CChar>, line: Int) {
        let type = LogType.warning(content: LogContent(item, className, line))
//        FwiLog.log(type)
    }
    
    static func info(_ item: Any, className: UnsafePointer<CChar>, line: Int) {
        let type = LogType.info(content: LogContent(item, className, line))
//        FwiLog.log(type)
    }
    
    static func debug(_ item: Any, className: UnsafePointer<CChar>, line: Int) {
        let type = LogType.debug(content: LogContent(item, className, line))
//        FwiLog.log(type)
    }
    
    static func verbose(_ item: Any, className: UnsafePointer<CChar>, line: Int) {
        let type = LogType.verbose(content: LogContent(item, className, line))
//        FwiLog.log(type)
    }
}
