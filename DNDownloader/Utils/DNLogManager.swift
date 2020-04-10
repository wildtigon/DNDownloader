//
//  DNLogManager.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

final class DNLogManager {
    static func show<T>(_ info: T, file: NSString = #file, method: String = #function, line: Int = #line) {
        switch DNDownloaderConfig.LOG_LEVEL {
        case .none:
            // Nothing to show
            break
        case .simple:
            print("DNDownloader: \(info)")
            
        case .detail:
            print("-----DNDownloader-----\n"
                + "File   : \(file.lastPathComponent)\n"
                + "Method : \(method)\n"
                + "Line   : [\(line)]\n"
                + "Info   : \(info)\n"
            )
        }
    }
}
