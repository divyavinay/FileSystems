//
//  Sector.swift
//  FileSystem
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

struct Sector {
    var directory: Directory?
    var file: DataFile?
    var next: Int
    var prev: Int
    
    init(directory: Directory?, file: DataFile?) {
        self.directory = directory
        self.file = file
        self.next = -1
        self.prev = -1
    }
}
