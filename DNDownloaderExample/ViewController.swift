//
//  ViewController.swift
//  DNDownloaderExample
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBAction private func onDownloadButtonClicked(_ sender: UIButton) {
        startDownloadWithoutHeader()
    }
    
    private func startDownloadWithHeaders() {
        let staticURL = "http://192.168.1.17:8181/api/v1/get_video/"
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
            
            return DownloadURL(stringURL: staticURL.appending(name), headers: headers)
        }
        
        print("Start downloading")
        download(requests: requests) {
            print("Finished downloading")
        }
    }
    
    private func startDownloadWithoutHeader() {
        let requests = [
            DownloadURL(stringURL: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/あああ.mp4"),
        DownloadURL(stringURL: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい.mov"),
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

