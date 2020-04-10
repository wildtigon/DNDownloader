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
        
        
        let url = URL(string: urls[1])!
        DNDownloader.shared.logLevel = .none
        DNDownloader.shared.download(with: url).completion { (result) in
            switch result {
            case .success(let uri):
                print("Success: \(uri)")
            case .failure(let error as NSError, let uri):
                if error.code ==  DNError.fileIsExist.rawValue, let uri = uri {
                    print("File exist: \(uri)")
                } else {
                    print("Failed: \(error.code)")
                }
            }
        }
        print("Start downloading")
        DNDownloader.shared.startAllTasks()
    }
}

