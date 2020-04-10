//
//  DNDownloaderConfig.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation
open class DNDownloaderConfig {
    static var DOWNLOAD_FOLDER = "Downloads"
    static var LOG_LEVEL: DNLogLevel = .detail
    static let DEFAULT_TIMEOUT: TimeInterval = 150
}

public enum DNResult<T> {
    case failure(Error, T?)
    case success(T)
}

public typealias ProgressCB = (_ progress : Progress) -> Void
public typealias SpeedCB = (_ speedBytes : Int64) -> Void
public typealias CompletionCB = (_ completion: DNResult<URL>) -> Void
public typealias Callback = (progress: ProgressCB?, speed: SpeedCB?, completion: CompletionCB?)

public enum DNLogLevel {
    case none, simple, detail
}

public let DNErrorDomain = "com.datnguyen.downloader.error"
public enum DNError: Int {
    case badURL = 9294
    case fileIsExist = 9793
    case fileInfoError = 9763
    case invalidStatusCode = 9669
    case diskOutOfSpace = 9501
    case downloadCanceled = -999
}
