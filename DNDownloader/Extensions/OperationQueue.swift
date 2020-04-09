//
//  OperationQueue.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

extension OperationQueue {
    static var downloadDelegateOperationQueue : OperationQueue {
        let downloadDelegateOperationQueue = OperationQueue()
        downloadDelegateOperationQueue.name = "com.datnguyen.downloader.queue.operation"
        return downloadDelegateOperationQueue
    }
}
