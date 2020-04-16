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
    var fileName: String?
    
    var tempPath: String {
        return DNCache.tempPath(url: url)
    }
    
    var downloadPath: String {
        return DNCache.downloadPath(with: self)
    }
    
    var downloadFileURL: URL {
        return URL(fileURLWithPath: DNCache.downloadPath(with: self))
    }
    
    init(session: URLSession, url: URL, headers: [String: Any], fileName: String?, timeout: TimeInterval) {
        self.progress = Progress()
        self.callbacks = []
        self.downloadTask = session.dataTask(with: url, headers: headers, timeout: timeout)
        self.url = url
        
        let pathEx = url.pathExtension
        if let fileName = fileName, pathEx.count > 0 {
            self.fileName = "\(fileName).\(pathEx)"
        }
        
    }
    
    func getFileName() -> String {
        return fileName ?? url.lastPathComponent
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

