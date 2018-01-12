//
//  Directory.swift
//  FileSystem
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

struct Directory {
    let blockNumber: Int
    var back_fixed: Int
    var frwd_fixed: Int
    var free_fixed: Int
    var directoryEntries = [DirectoryEntry]()
}
