//
//  DNCache.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNCache {
    public static var downloadsDirectory :String = DNDownloaderConfig.DOWNLOAD_FOLDER {
        willSet {
            DNFileManager.shared.createDirectory(atPath: newValue.downDir)
        }
    }
    
    static func tempPath(url : URL ) -> String{
        return url.absoluteString.md5.tmpDir
    }
    
    static func downloadPath(url : URL ) -> String{
        return downloadsDirectory.downDir + "/" + url.lastPathComponent
    }
    
    static func removeTempFile(with url:URL){
        let path = tempPath(url: url)
        DNFileManager.shared.deleteFile(atPath: path)
    }
    
    static func removeDownloadedFile(with url: URL){
        let path = downloadPath(url: url)
        DNFileManager.shared.deleteFile(atPath: path)
    }
    
    public static func downloadedFilesSize() -> Int64{
        let downDir = downloadsDirectory.downDir
        return DNFileManager.shared.getFilesSize(downDir)
    }
    
    public static func cleanDownloadTempFiles(){
        do {
            let subpaths = try FileManager.default.subpathsOfDirectory(atPath: "".tmpDir)
            subpaths.forEach{
                let tempFilepath = "".tmpDir + "/" + $0
                
                DNFileManager.shared.deleteFile(atPath: tempFilepath)
            }
        } catch  {
            DNLogManager.show(error)
        }
    }

    static func cleanDownloadFiles(){
        DNFileManager.shared.deleteFile(atPath: downloadsDirectory.downDir)
        DNFileManager.shared.createDirectory(atPath: downloadsDirectory.downDir)
    }
    
    static func pathsOfDownloadedfiles() -> [String]{
        var paths = [String]()
        do {
            let subpaths = try FileManager.default.subpathsOfDirectory(atPath: downloadsDirectory.downDir)
            subpaths.forEach{
                let filepath = downloadsDirectory.downDir + "/" + $0
                paths.append(filepath)
            }
        } catch {
            DNLogManager.show(error)
        }
        return paths
    }
}
