//
//  DNURL.swift
//  DNDownloader
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import Foundation

public protocol DNURL {
    func asURL() throws -> URL
}

extension String: DNURL {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw NSError(domain: DNErrorDomain,
                          code: DNError.badURL.rawValue,
                          userInfo: ["url": self])
        }
        return url
    }
}

extension URL: DNURL {
    public func asURL() throws -> URL {
        return self
    }
}
