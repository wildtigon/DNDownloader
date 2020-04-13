//
//  URLSession.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

extension URLSession {
    func dataTask(with url : URL,timeout:TimeInterval) -> URLSessionDataTask{
        let range  = DNFileManager.shared.fileSize(filePath: DNCache.tempPath(url: url))
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        let headRange = "bytes=" + String(range) + "-"
        request.setValue(headRange, forHTTPHeaderField: "Range")
        
        let task = dataTask(with: request)
        task.priority = URLSessionTask.defaultPriority
        return task
    }
}
