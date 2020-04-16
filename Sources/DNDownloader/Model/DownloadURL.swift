//
//  DownloadURL.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/16/20.
//

import Foundation

struct DownloadURL {
    let url: URL
    var headers: [String: String] = [:]
    
    init(stringURL: String, headers: [String: String] = [:]) {
        self.url = URL(string: stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        self.headers = headers
    }
}
