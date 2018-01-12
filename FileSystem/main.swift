// PROJEECT NAME: File Systems
// LANGUAGE: Swift
// NAME: Divya Basappa

import Foundation

let fileSystem = FileSystem()
let helper = Helper(fileSystem: fileSystem)
fileSystem.initializeList()
fileSystem.createRootDirectory()
helper.getCommand()
print("Enter Y to continue")
let cont = readLine()
while cont != "N" {
    helper.getCommand()
}


