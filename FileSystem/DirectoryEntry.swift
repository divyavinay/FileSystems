//
//  DirectoryEntry.swift
//  FileSystem
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

struct DirectoryEntry {
    var type: Character
    var name: String
    var link_fixed: Int
    var size_fixed: Int
    
    init() {
        type = "F"
        name = ""
        link_fixed = -1
        size_fixed = -1
    }
}
