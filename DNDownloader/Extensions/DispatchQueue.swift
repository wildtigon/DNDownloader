//
//  DispatchQueue.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let barrier  = DispatchQueue(label: "com.datnguyen.downloader.thread.barrier", attributes: .concurrent)
    static let cancel   = DispatchQueue(label: "com.datnguyen.downloader.thread.cancel",  attributes: .concurrent)
    static let download = DispatchQueue(label: "com.datnguyen.downloader.thread.download",attributes: .concurrent)
    
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
