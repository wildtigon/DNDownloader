//
//  DNFileManager.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public class DNFileManager {
    static let shared = DNFileManager()
    private init (){}
    
    func createDirectory(atPath:String) {
        if isFileNotExist(atPath: atPath)  {
            do {
                try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                DNLogManager.show(error)
            }
        }
    }
    
    func isFileExist(atPath filePath : String ) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    func isFileNotExist(atPath filePath : String ) -> Bool {
        return !isFileExist(atPath: filePath)
    }
    
    func deleteFile(atPath: String) {
        guard isFileExist(atPath: atPath) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath:atPath )
        } catch  {
            DNLogManager.show(error)
        }
    }
    
    func getFilesSize(_ cacheDir: String) -> Int64{
        if DNFileManager.shared.isFileNotExist(atPath: cacheDir) {
            return 0
        }
        do {
            var filesSize : Int64 = 0
            let subpaths = try FileManager.default.subpathsOfDirectory(atPath: cacheDir)
            
            subpaths.forEach{
                let filepath = cacheDir + "/" + $0
                filesSize += fileSize(filePath: filepath)
            }
            return filesSize
            
        } catch  {
            DNLogManager.show(error)
            return 0
        }
    }
    
    func fileSize(filePath : String ) -> Int64 {
        guard isFileExist(atPath: filePath) else { return 0 }
        let fileInfo =   try! FileManager.default.attributesOfItem(atPath: filePath)
        return fileInfo[FileAttributeKey.size] as! Int64
    }
    
    func moveItem(atPath: String, toPath: String) {
        do {
            try FileManager.default.moveItem(atPath: atPath, toPath: toPath)
        } catch  {
            DNLogManager.show(error)
        }
    }
    
    func systemFreeSize() -> Int64{
        do {
            let attributes =  try FileManager.default.attributesOfFileSystem(forPath:  NSHomeDirectory())
            let freesize = attributes[FileAttributeKey.systemFreeSize] as? Int64
            return freesize ?? 0
        } catch {
            DNLogManager.show(error)
            return 0
        }
    }
}
