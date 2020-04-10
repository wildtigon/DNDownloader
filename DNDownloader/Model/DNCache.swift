//
//  DNCache.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNCache {
    public static var cachesDirectory :String = DNDownloaderConfig.DOWNLOAD_FOLDER {
        willSet {
            DNFileManager.shared.createDirectory(atPath: newValue.cacheDir)
        }
    }
    
    static func tempPath(url : URL ) -> String{
        return url.absoluteString.md5.tmpDir
    }
    
    static func cachePath(url : URL ) -> String{
        return cachesDirectory.cacheDir + "/" + url.lastPathComponent
    }
    
    static func removeTempFile(with url:URL){
        let fileTempPath = tempPath(url: url)
        DNFileManager.shared.deleteFile(atPath: fileTempPath)
    }
    
    static func removeCacheFile(with url:URL){
        let fileCachePath = cachePath(url: url)
        DNFileManager.shared.deleteFile(atPath: fileCachePath)
    }
    
    public static func downloadedFilesSize() -> Int64{
        let cacheDir = cachesDirectory.cacheDir
        return DNFileManager.shared.getFilesSize(cacheDir)
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
        DNFileManager.shared.deleteFile(atPath: cachesDirectory.cacheDir)
        DNFileManager.shared.createDirectory(atPath: cachesDirectory.cacheDir)
    }
    
    static func pathsOfDownloadedfiles() -> [String]{
        var paths = [String]()
        do {
            let subpaths = try FileManager.default.subpathsOfDirectory(atPath: cachesDirectory.cacheDir)
            subpaths.forEach{
                let filepath = cachesDirectory.cacheDir + "/" + $0
                paths.append(filepath)
            }
        } catch {
            DNLogManager.show(error)
        }
        return paths
    }
}
