//
//  ViewController.swift
//  DNDownloaderExample
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import UIKit

struct DownloadURL {
    let url: URL
    var headers: [String: String] = [:]
}

final class ViewController: UIViewController {
    
    @IBAction private func onDownloadButtonClicked(_ sender: UIButton) {
      startDownloadWithHeaders()
    }
    
    private func startDownloadWithHeaders() {
        let staticURL = URL(string: "http://192.168.1.17:8181/api/v1/get_video/")!
        let fileNames = [
            "movie_1.mp4",
            "movie_2.mp4",
            "movie_3.mp4",
        ]
        
        let requests = fileNames.map { (name) -> DownloadURL in
            let headers: [String: String] = [
                "company_code": "VN1015",
                "store_code": "001",
            ]
            
            return DownloadURL(url: staticURL.appendingPathComponent(name), headers: headers)
        }
        
        print("Start downloading")
        download(requests: requests) {
            print("Finished downloading")
        }
    }
    
    private func startDownloadWithoutHeader() {
        let requests = [
            DownloadURL(url: URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_1.mp4")!),
            DownloadURL(url: URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_2.mp4")!),
            DownloadURL(url: URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_3.mp4")!),
            DownloadURL(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
            DownloadURL(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!),
            DownloadURL(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!),
            DownloadURL(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!),
            DownloadURL(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!),
        ]
        
        print("Start downloading")
        download(requests: requests) {
            print("Finished downloading")
        }
    }
    
    private func download(requests: [DownloadURL], completion: @escaping(()->())) {
        guard requests.count > 0 else {
            completion()
            return
        }
        
        DNCache.cleanDownloadTempFiles()
        let group = DispatchGroup()
        
        requests.forEach{ (req) in
            DNDownloader.shared.download(with: req.url, headers: req.headers).completion { (result) in
                switch result {
                case .success(let uri):
                    print("Success: \(uri)")
                case .failure(let error as NSError, let uri):
                    if error.code == DNError.fileIsExist.rawValue, let uri = uri {
                        print("File exits: \(uri)")
                    } else {
                        print("Failed: \(error)")
                    }
                }
                group.leave()
            }
            group.enter()
        }
        
        DNDownloader.shared.startAllTasks()
        
        group.notify(queue: .main) {
            completion()
        }
    }
}

