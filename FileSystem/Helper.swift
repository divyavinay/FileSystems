//
//  Helper.swift
//  FileSystem
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

class Helper {
    private var fileSystem: FileSystem
    
    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }
    
   func getCommand() {
        print("Enter Command")
        let commad =  readLine()
        let commandArr = commad?.components(separatedBy: " ")
        
        var commandType = ""
        var type = ""
        var name = ""
        
        commandType = commandArr![0]
        if commandArr!.count > 1 {
            if commandArr?.count == 2 {
                name = commandArr![1]
            }
            else {
                type = commandArr![1]
                if commandArr!.count > 3 {
                    let arr = commad?.components(separatedBy: "'")
                    name = arr![1]
                }
                else {
                    name = commandArr![2]
                }
            }
        }
        
        switch commandType {
        case "CREATE":
            fileSystem.Dwrite(commandType: "Create", type: type, filePath: name, numberOfBytes: nil)
        case "DELETE":
            fileSystem.Dwrite(commandType: "Delete",type: type, filePath: name, numberOfBytes: nil)
        case "OPEN":
            fileSystem.Dread(commandType: "Open",type: type, filePath: name, numberOfBytes: nil)
        case "CLOSE":
            fileSystem.Dread(commandType: "Close",type: type, filePath: name, numberOfBytes: nil)
        case "WRITE":
            fileSystem.Dwrite(commandType: "Write",type: nil, filePath: name, numberOfBytes: Int(type))
        case "READ":
            fileSystem.Dread(commandType: "Read", type: nil, filePath: fileSystem.lastCreatedFileName, numberOfBytes: Int(name))
        case "SEEK":
            fileSystem.Dread(commandType: "Seek", type: type, filePath: fileSystem.lastCreatedFileName, numberOfBytes: Int(name))
        default:
            print("Defualt")
        }
        
        if commandType == "CREATE" { print("Path: \(name)")}
        print("Number of Directories: \(fileSystem.numberOfDir)")
        print("Number of user files: \(fileSystem.numberOfFiles)")
        print("Number of free block:\(fileSystem.MAX_DISK_SPACE - fileSystem.m_head_free_list)")
    }
}



