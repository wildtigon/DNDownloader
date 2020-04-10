//
//  DNDownloaderDelegate.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

final public class DNDownloaderDelegate: NSObject {
    var downloader: DNDownloader?
}

extension DNDownloaderDelegate: URLSessionDataDelegate, URLSessionDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let downloader = downloader, let url = dataTask.originalRequest?.url, let seed = downloader.findSeed(with: url) else {
            return
        }
        
        // the file has been downloaded
        if  DNFileManager.shared.isFileExist(atPath: DNCache.downloadPath(url: url)){
            let downloadedURI =  URL(fileURLWithPath: DNCache.downloadPath(url: url))
            let errorInfo = ["file downloaded": downloadedURI]
            let error = NSError(domain: DNErrorDomain, code: DNError.fileIsExist.rawValue, userInfo: errorInfo)
            onComplete(.failure(error, downloadedURI), seed)
            return
        }
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
            !(200..<400).contains(statusCode){
            
            let error = NSError(domain: DNErrorDomain,
                                code: DNError.invalidStatusCode.rawValue,
                                userInfo: ["statusCode": statusCode, NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)])
            
            onComplete(.failure(error, nil), seed)
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
            let errorInfo = ["out of space": url]
            let error = NSError(domain: DNErrorDomain, code: DNError.diskOutOfSpace.rawValue, userInfo: errorInfo)
            
            onComplete(.failure(error, nil), seed)
            return
        }
        
        guard seed.progress.fractionCompleted <= 1.0 else {
            // File error
            DNFileManager.shared.deleteFile(atPath: seed.tempPath)
            let error = NSError(domain: DNErrorDomain, code: DNError.fileInfoError.rawValue, userInfo: nil)
            onComplete(.failure(error, nil), seed)
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.downloadPath)
            return
        }
        
        guard seed.progress.fractionCompleted != 1.0 else {
            // File exists
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.downloadPath)
            onComplete(.success(seed.downloadFileURL), seed)
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
        onProgress(seed)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloader = downloader, let url = task.originalRequest?.url, let seed = downloader.findSeed(with: url) else {
            return
        }
        
        if let errorInfo = error  {
            onComplete(.failure(errorInfo, nil), seed)
        } else {
            onComplete(.success(seed.downloadFileURL), seed)
        }
        seed.outputStream?.close()
    }
}

extension DNDownloaderDelegate {
    func onProgress(_ seed : DNSeed){
        onUpdateSpeed(seed)
        DispatchQueue.main.safeAsync {
            seed.callbacks.forEach{ $0.progress?(seed.progress) }
        }
    }
    
    func onComplete(_ result: DNResult<URL>,_ seed: DNSeed){
        guard let downloader = self.downloader else { return  }
        switch result {
        case .failure(let error as NSError, _):
            if error.code == DNError.downloadCanceled.rawValue {
                // If a task is cancelled, the temporary file will be deleted
                DNFileManager.shared.deleteFile(atPath: seed.tempPath)
            }
            DNLogManager.show(error)
            
        case .success(_) :
            DNFileManager.shared.moveItem(atPath: seed.tempPath, toPath: seed.downloadPath)
            DNLogManager.show("Download success")
        }
        
        downloader.removeSeed(for: seed.url)
        
        DispatchQueue.main.safeAsync {
            seed.callbacks.forEach{ $0.completion?(result) }
        }
        onSuspend(seed)
    }
    
    func onUpdateSpeed(_ diggerSeed : DNSeed) {
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
    
    func onSuspend(_ diggerSeed : DNSeed){
        DispatchQueue.main.safeAsync {
            diggerSeed.callbacks.forEach{ $0.speed?(0) }
        }
    }
}
