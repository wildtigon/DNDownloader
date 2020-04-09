//
//  ViewController.swift
//  DNDownloaderExample
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    let urls = [
        "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_1.mp4",
        "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_2.mp4",
        "http://ec2-3-0-94-84.ap-southeast-1.compute.amazonaws.com/datnguyen/s3/public/videos/movie_3.mp4"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Start downloading")
       
        let url = URL(string: urls[1])!
        DNCache.cleanDownloadFiles()
        DNCache.cleanDownloadTempFiles()
        DNDownloader.shared.logLevel = .simple
        DNDownloader.shared.download(with: url).completion { (result) in
            switch result {
                case .success(let url):
                    print("Success: \(url)")
                case .failure(let error):
                    print("Failed: \(error)")
                }
            }
    }
}

