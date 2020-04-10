//
//  ViewController.swift
//  DNDownloaderExample
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let urls = [
        URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_1.mp4")!,
        URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_2.mp4")!,
        URL(string: "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_3.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
    ]
    
    @IBAction private func onDownloadButtonClicked(_ sender: UIButton) {
        print("Start downloading")
        download(videoURLs: urls) {
            print("Finished downloading")
        }
    }
    
    private func download(videoURLs: [URL], completion: @escaping(()->())) {
        guard videoURLs.count > 0 else {
            completion()
            return
        }
        
        DNCache.cleanDownloadTempFiles()
        let group = DispatchGroup()
        
        videoURLs.forEach{ (url) in
            DNDownloader.shared.download(with: url).completion { (result) in
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

