//
//  URLSession.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

extension URLSession {
    func dataTask(with url : URL, headers: [String: Any], timeout:TimeInterval) -> URLSessionDataTask{
        let range = DNFileManager.shared.fileSize(filePath: DNCache.tempPath(url: url))
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
                
        let headRange = "bytes=" + String(range) + "-"
        request.addValue(headRange, forHTTPHeaderField: "Range")
        
        headers.compactMapValues({$0 as? String}).forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }
        
        let task = dataTask(with: request)
        task.priority = URLSessionTask.defaultPriority
        return task
    }
}
