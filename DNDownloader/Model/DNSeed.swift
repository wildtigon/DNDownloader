//
//  DNSeed.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNSeed {
    var downloadTask: URLSessionDataTask
    var url: URL
    var progress: Progress
    var callbacks: [Callback]
    var cancelSemaphore: DispatchSemaphore?
    var outputStream: OutputStream?
    
    var tempPath: String {
        return DNCache.tempPath(url: url)
    }
    
    var cachePath: String {
        return DNCache.cachePath(url: url)
    }
    
    var cacheFileURL: URL {
        return URL(fileURLWithPath: DNCache.cachePath(url: url))
    }
    
    init(session: URLSession, url: URL, timeout: TimeInterval) {
        self.progress = Progress()
        self.callbacks = []
        self.downloadTask = session.dataTask(with: url, timeout: timeout)
        self.url = url
    }
    
    @discardableResult
    public func progress(_ progress: @escaping ProgressCB) -> Self {
        let callback = Callback(progress, nil, nil)
        callbacks.append(callback)
        
        return self
    }
    
    @discardableResult
    public func speed(_ speed:  @escaping SpeedCB) -> Self {
        let callback = Callback(nil, speed, nil)
        callbacks.append(callback)
        
        return self
    }
    
    @discardableResult
    public func completion(_ completion:  @escaping CompletionCB) -> Self {
        let callback = Callback(nil, nil, completion)
        callbacks.append(callback)
        
        return self
    }
}

