//
//  DNDownloader.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNDownloader: DNDownloaderProtocol {
    public static let shared = DNDownloader()
    
    open var logLevel: DNLogLevel = .simple {
        didSet {
            DNDownloaderConfig.LOG_LEVEL = logLevel
        }
    }
    open var startImmediately = true
    open var timeout: TimeInterval = DNDownloaderConfig.DEFAULT_TIMEOUT
    
    private var seeds: [URL: DNSeed] = [:]
    private var session: URLSession
    
    private var downloaderDelegate: DNDownloaderDelegate?
    private let barrierQueue: DispatchQueue = .barrier
    private let delegateQueue: OperationQueue = .downloadDelegateOperationQueue
    
    public var maxConcurrent: Int = 2 {
        didSet {
            let concurrent = maxConcurrent == 0 ?  1 : maxConcurrent
            session.invalidateAndCancel()
            session = setupSession(concurrent)
        }
    }
    
    private init(path: String = "") {
        if path.isEmpty {
            DNCache.cachesDirectory = DNDownloaderConfig.DOWNLOAD_FOLDER
        } else {
            DNCache.cachesDirectory = path
        }
        downloaderDelegate = DNDownloaderDelegate()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = maxConcurrent
        session = URLSession(configuration: sessionConfiguration,
                             delegate: downloaderDelegate,
                             delegateQueue: delegateQueue)
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    private func setupSession(_ maxConcurrent: Int ) -> URLSession{
        downloaderDelegate = DNDownloaderDelegate()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = maxConcurrent
        let session = URLSession(configuration: sessionConfiguration, delegate: downloaderDelegate, delegateQueue: delegateQueue)
        
        return session
    }
    
    @discardableResult
    public func download(with url: DNURL) -> DNSeed {
        switch isURLCorrect(url) {
        case .success(let url):
            return createSeed(with: url)
        case .failure(_):
            fatalError("Please make sure the url or urlString is correct")
        }
    }
}

extension DNDownloader{
    private func createSeed(with url: URL) -> DNSeed {
        if let seed = findSeed(with: url) {
            return seed
        } else {
            barrierQueue.sync(flags: .barrier){
                let timeout = self.timeout == 0.0 ? DNDownloaderConfig.DEFAULT_TIMEOUT : self.timeout
                seeds[url] = DNSeed(session: session, url: url, timeout: timeout)
            }
            
            let seed = findSeed(with: url)!
            downloaderDelegate?.downloader = self
            
            if startImmediately{
                seed.downloadTask.resume()
            }
            return seed
        }
    }
    
    func removeSeed(for url : URL){
        barrierQueue.sync(flags: .barrier) {
            seeds.removeValue(forKey: url)
            if seeds.isEmpty{
                downloaderDelegate = nil
            }
        }
    }
    
    func isURLCorrect(_ url: DNURL) -> DNResult<URL> {
        var correctURL: URL
        do {
            correctURL = try url.asURL()
            return .success(correctURL)
        } catch {
            DNLogManager.show(error)
            return .failure(error)
        }
    }
    
    func findSeed(with url: DNURL) -> DNSeed? {
        var seed: DNSeed?
        switch isURLCorrect(url) {
        case .success(let value):
            barrierQueue.sync(flags: .barrier) {
                seed = seeds[value]
            }
            return seed
        case .failure(_):
            return seed
        }
    }
}

extension DNDownloader{
    public func cancelTask(for url: DNURL) {
        switch isURLCorrect(url) {
        case .failure(_):
            return
        case .success(let value):
            barrierQueue.sync(flags: .barrier){
                guard let seed = seeds[value] else {
                    return
                }
                seed.downloadTask.cancel()
            }
        }
    }
    
    public func stopTask(for url: DNURL) {
        switch isURLCorrect(url) {
        case .failure(_):
            return
        case .success(let value):
            barrierQueue.sync(flags: .barrier){
                guard let seed = seeds[value] else {
                    return
                }
                if seed.downloadTask.state == .running{
                    seed.downloadTask.suspend()
                    downloaderDelegate?.notifySpeedZeroCallback(seed)
                }
            }
        }
    }
    
    public func startTask(for url: DNURL) {
        switch isURLCorrect(url) {
        case .failure(_):
            return
            
        case .success(let value):
            barrierQueue.sync(flags: .barrier){
                guard let seed = seeds[value] else {
                    return
                }
                
                if seed.downloadTask.state != .running {
                    seed.downloadTask.resume()
                    downloaderDelegate?.notifySpeedCallback(seed)
                }
            }
        }
    }
    
    public func startAllTasks() {
        seeds.keys.forEach{  (url) in
            startTask(for: url)
        }
    }
    
    public func stopAllTasks()  {
        seeds.keys.forEach{ (url) in
            stopTask(for : url)
        }
    }
    
    public func cancelAllTasks()  {
        seeds.keys.forEach{ (url) in
            cancelTask(for: url)
        }
    }
}
