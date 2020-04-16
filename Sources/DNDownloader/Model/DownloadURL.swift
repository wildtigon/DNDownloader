//
//  DownloadURL.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/16/20.
//

import Foundation

public protocol DownloadURLProtocol {
    var url: URL { get }
    var headers: [String: String] { get }
    var fileName: String? { get }
    
    init(stringURL: String, headers: [String: String], fileName: String?)
}
