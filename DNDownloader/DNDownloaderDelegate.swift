//
//  DNDownloaderDelegate.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNDownloaderDelegate: NSObject {
    var downloader: DNDownloader?
}

extension DNDownloaderDelegate: URLSessionDataDelegate, URLSessionDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let downloader = downloader, let url = dataTask.originalRequest?.url, let seed = downloader.findSeed(with: url) else {
            return
        }
        
        // the file has been downloaded
        if  DNFileManager.shared.isFileExist(atPath: DNCache.cachePath(url: url)){
            let cachesURL =  URL(fileURLWithPath: DNCache.cachePath(url: url))
            let errorInfo = ["file downloaded":cachesURL]
            let error = NSError(domain: DNErrorDomain, code: DNError.fileIsExist.rawValue, userInfo: errorInfo)
            notifyCompletionCallback(.failure(error), seed)
            return
        }
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
            !(200..<400).contains(statusCode){
            
            let error = NSError(domain: DNErrorDomain,
                                code: DNError.invalidStatusCode.rawValue,
                                userInfo: ["statusCode": statusCode, NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)])
            
            notifyCompletionCallback(.failure(error), seed)
            return
        }
        
        guard let responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String:String] else {
            return
        }
        
        if let totalBytesString = responseHeaders["Content-Range"]?.components(separatedBy: "-").last?.components(separatedBy: "/").last ,
            let totalBytes = Int64(totalBytesString)  {
            seed.progress.totalUnitCount = totalBytes
        }
        
        if let completedBytesString = responseHeaders["Content-Range"]?.components(separatedBy: "-").first?.components(separatedBy: " ").last ,
            let completedBytes = Int64(completedBytesString)  {
            
            seed.progress.completedUnitCount = completedBytes
        }
        
        if  seed.progress.totalUnitCount >= DNFileManager.shared.systemFreeSize(){
            let errorInfo = ["out of space":url]
            let error = NSError(domain: DNErrorDomain, code: DNError.diskOutOfSpace.rawValue, userInfo: errorInfo)
            
            notifyCompletionCallback(.failure(error), seed)
            
            return
        }
        
        guard seed.progress.fractionCompleted <= 1.0 else {
            // File error
            DNFileManager.shared.deleteFile(atPath: seed.tempPath)
            let error = NSError(domain: DNErrorDomain, code: DNError.fileInfoError.rawValue, userInfo: nil)
            notifyCompletionCallback(.failure(error), seed)
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.cachePath)
            return
        }
        
        guard seed.progress.fractionCompleted != 1.0 else {
            // File exists
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.cachePath)
            notifyCompletionCallback(.success(seed.cacheFileURL), seed)
            
            return
        }
        
        seed.outputStream = OutputStream(toFileAtPath: seed.tempPath, append: true)
        seed.outputStream?.open()
        
        DNLogManager.show("start to download \n" + url.absoluteString)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let downloader = downloader, let url = dataTask.originalRequest?.url, let seed = downloader.findSeed(with: url) else {
            return
        }
        
        seed.progress.completedUnitCount += Int64((data as NSData).length)
        let buffer = [UInt8](data)
        
        seed.outputStream?.write(buffer, maxLength: (data as NSData).length)
        notifyProgressCallback(seed)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloader = downloader, let url = task.originalRequest?.url, let seed = downloader.findSeed(with: url) else {
            return
        }
        
        if let errorInfo = error  {
            notifyCompletionCallback( .failure(errorInfo), seed)
        } else {
            notifyCompletionCallback( .success(seed.cacheFileURL), seed)
        }
        seed.outputStream?.close()
    }
}

extension DNDownloaderDelegate {
    func notifyProgressCallback(_ seed : DNSeed){
        notifySpeedCallback(seed)
        DispatchQueue.main.safeAsync {
            seed.callbacks.forEach{ $0.progress?(seed.progress) }
        }
    }
    
    func notifyCompletionCallback(_ result: DNResult<URL>,_ seed: DNSeed){
        guard let downloader = self.downloader else { return  }
        switch result {
        case .failure(let error as NSError):
            if error.code == DNError.downloadCanceled.rawValue {
                // If a task is cancelled, the temporary file will be deleted
                DNFileManager.shared.deleteFile(atPath: seed.tempPath)
            }
            DNLogManager.show(error)
            
        case .success(_) :
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.cachePath)
            DNLogManager.show("Download success")
        }
        
        downloader.removeSeed(for: seed.url)
        
        DispatchQueue.main.safeAsync {
            seed.callbacks.forEach{ $0.completion?(result) }
        }
        notifySpeedZeroCallback(seed)
    }
    
    func notifySpeedCallback(_ diggerSeed : DNSeed) {
        let progress = diggerSeed.progress
        var dataCount = progress.completedUnitCount
        let time = Double(NSDate().timeIntervalSince1970)
        var lastData:Int64 = 0
        var lastTime:Double = 0
        
        if progress.userInfo[.throughputKey] != nil {
            lastData = progress.userInfo[.fileCompletedCountKey] as! Int64
        } else {
            dataCount = 0
        }
        
        if progress.userInfo[.estimatedTimeRemainingKey] != nil {
            lastTime = progress.userInfo[.estimatedTimeRemainingKey] as! Double
        }
        
        if (time - lastTime) <= 1.0 {
            return
        }
        
        let speed = Int64(Double( dataCount - lastData) / ( time - lastTime) )
        progress.setUserInfoObject(dataCount, forKey: .fileCompletedCountKey)
        progress.setUserInfoObject(time, forKey: .estimatedTimeRemainingKey)
        progress.setUserInfoObject(speed, forKey: .throughputKey)
        
        if let speed = progress.userInfo[.throughputKey] as? Int64 {
            DispatchQueue.main.safeAsync {
                diggerSeed.callbacks.forEach{ $0.speed?(speed) }
            }
        }
    }
    
    func notifySpeedZeroCallback(_ diggerSeed : DNSeed){
        DispatchQueue.main.safeAsync {
            diggerSeed.callbacks.forEach{ $0.speed?(0) }
        }
    }
}
