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
    
    var downloadPath: String {
        return DNCache.downloadPath(url: url)
    }
    
    var downloadFileURL: URL {
        return URL(fileURLWithPath: DNCache.downloadPath(url: url))
    }
    
    init(session: URLSession, url: URL, headers: [String: Any], timeout: TimeInterval) {
        self.progress = Progress()
        self.callbacks = []
        self.downloadTask = session.dataTask(with: url, headers: headers, timeout: timeout)
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

