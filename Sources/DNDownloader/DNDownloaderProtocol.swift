//
//  DNDownloaderProtocol.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

protocol DNDownloaderProtocol{
    var logLevel: DNLogLevel { set get }
    var downloadFolder: String { set get }
    var maxConcurrent: Int {set get }
    
    var timeout: TimeInterval { set get }
    var startImmediately: Bool { set get }
    
    func startTask(for diggerURL: DNURL)
    func startAllTasks()
    
    func stopTask(for diggerURL: DNURL)
    func stopAllTasks()
    
    func cancelTask(for diggerURL: DNURL)
    func cancelAllTasks()
    
    func clearAllFiles()
    func getDownloadedURI(from url: URL) -> String
}
