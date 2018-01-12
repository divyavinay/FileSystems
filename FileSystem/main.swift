// PROJEECT NAME: File Systems
// LANGUAGE: Swift
// NAME: Divya Basappa

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

struct Directory {
    let blockNumber: Int
    var back_fixed: Int
    var frwd_fixed: Int
    var free_fixed: Int
    var directoryEntries = [DirectoryEntry]()
}

struct DataFile {
    var back_fixed: Int
    var frwd_fixed: Int
    var user_data: String
    var mode: Character
}

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

// adding a directory to the disk

var disk = [Sector]()
let MAX_DISK_SPACE = 100
var lastCreatedFileName: String = ""
var numberOfDir = 0
var numberOfFiles = 0

// function to initialize the disk. It creates sector objects with next and prev.
func initializeList() {
    var count = 0
    while count < MAX_DISK_SPACE {
        // creates an object of struct sector and passing file and directory as nil
        var sector = Sector(directory: nil, file: nil)
        sector.next = count + 1
        sector.prev = count - 1
        disk.append(sector)
        count += 1
    }
}

var m_head_free_list = 1

// create root directory in index 0 of disk
func createRootDirectory() {
    let root = Directory(blockNumber: 0, back_fixed: 0, frwd_fixed: 0, free_fixed: 1, directoryEntries: createDirectoryEntries())
    disk[0].directory = root
}

// all disk manipulation commands are done through this function
func Dwrite(commandType: String, type: String?, filePath: String, numberOfBytes: Int?) {
    switch commandType {
    case "Create":
        createFileOrDir(type: type!, filePath: filePath)
    case "Delete":
        deleteFile(filePath: filePath)
    case "Write":
       writeToFile(bytesOFData: numberOfBytes!, data: filePath)
    default:
        return
    }
}

func Dread (commandType: String, type: String?, filePath: String, numberOfBytes: Int?) {
    switch commandType {
    case "Close":
        closeFile()
    case "Open":
        openFile(mode: type!, filePath: filePath)
    case "Read":
        readFile(numberOfBytes: numberOfBytes!, filePath: filePath)
    case "Seek":
        seekFile(base: Int(type!)!, offset: numberOfBytes!)
    default:
        return
    }
}

func seekFile(base: Int, offset: Int) {
    var filePathArr = lastCreatedFileName.components(separatedBy: "/")
    var diskIndex = 0;
    let fileName = filePathArr.removeLast()
    for i in 0..<filePathArr.count {
        // get the location of the directory the file is in
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
    }
    
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == fileName {
            // once the file is located in directory get the block number of the file
            let fileDestination = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            if disk[fileDestination].file?.mode == "I" || disk[fileDestination].file?.mode == "U" {
                let filePointerCurrent = disk[fileDestination].file?.user_data.data(using: .utf8)?.count
                let beginningOfFile = 0
                let endOfFile = 504
                
                if base == -1 {
                    print("location of file pointer: \(beginningOfFile + offset)")
                }
                else if base == 0 {
                    print("location of file pointer: \(filePointerCurrent! + offset)")
                }
                else if base == 1 {
                    print("location of file pointer: \(endOfFile + offset)")
                }
            }
        }
    }
}


// Name: readFile - function for reading data from file.
// Paramters: filePath: indicates the path of file in file system, numberOfBytes: number of bytes of data that should be read.
func readFile(numberOfBytes: Int, filePath:String) {
    var filePathArr = lastCreatedFileName.components(separatedBy: "/")
    var diskIndex = 0;
    let fileName = filePathArr.removeLast()
    for i in 0..<filePathArr.count {
        // get the location of the directory the file is in
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
    }
    // loop through the directory entries to find the file
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == fileName {
            // once the file is located in directory get the block number of the file
            var fileDestination = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            if disk[fileDestination].file?.mode == "I" || disk[fileDestination].file?.mode == "U" {
                print(disk[fileDestination].file?.user_data.data(using: .utf8)?.count)
                if (disk[fileDestination].file?.user_data.data(using: .utf8)?.count)! > numberOfBytes {
                    let splitData = splitString(str: (disk[fileDestination].file?.user_data)!, threshold: numberOfBytes)
                    print(splitData.0)
                }
                else {
                    if numberOfBytes > 504 {
                        if disk[fileDestination].file?.frwd_fixed != 0 {
                            let dataPrevBlock = disk[fileDestination].file?.user_data
                            fileDestination = (disk[fileDestination].file?.frwd_fixed)!
                            var x = dataPrevBlock?.count
                            x = numberOfBytes - x!
                            let newData = splitString(str: (disk[fileDestination].file?.user_data)!, threshold: x!)
                            print(dataPrevBlock! + newData.0)
                        }
                    }
                    else {
                        let splitData = splitString(str: (disk[fileDestination].file?.user_data)!, threshold: numberOfBytes)
                        print(splitData.0)
                    }
                }
            }
            else {
                print("File not in correct mode")
            }
        }
    }
}

// Name: WriteToFile - Function to write to file
//Parameters: bytesOfData: number of bytes of data that needs to be written to file, data: data that needs to be written to file
func writeToFile(bytesOFData: Int,data: String ) {
    var filePathArr = lastCreatedFileName.components(separatedBy: "/")
    var diskIndex = 0;
    let fileName = filePathArr.removeLast()
    // find the directory in which the file is in
    for i in 0..<filePathArr.count {
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
    }
    
    // loop through directory entries and find file
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == fileName {
            // get the block number of file in disk
            let fileDestination = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            
            // check if the file is in the write mode for write operation
            if disk[fileDestination].file?.mode == "O" || disk[fileDestination].file?.mode == "U" {
                // get the number of bytes of data
                let dataSize = data.data(using: .utf8)
                let x = dataSize!.count
               
                // if the number of bytes is same as input, write the file
                if x == bytesOFData {
                    disk[fileDestination].file?.user_data = data
                }
                // if the input for number of bytes is greater than the number of bytes of data append space
                else {
                    if x > bytesOFData {
                        if x > 504 {
                            let splitData = splitString(str: data, threshold: 504)
                            disk[fileDestination].file?.user_data = splitData.0
                            disk[fileDestination].file?.frwd_fixed = m_head_free_list
                            let newDataBlock = DataFile(back_fixed: fileDestination, frwd_fixed: 0, user_data: splitData.1, mode: "O")
                            disk[m_head_free_list].file = newDataBlock
                            m_head_free_list += 1
                            
                        }
                        else {
                            let splitData = splitString(str: data, threshold: bytesOFData)
                            disk[fileDestination].file?.user_data = splitData.0
                        }
                    }
                    else {
                        var newData = data
                        var currentDataSize = dataSize!.count
                        // append space to the data entered by user
                        repeat {
                            newData = newData + " "
                            currentDataSize = newData.data(using: .utf8)!.count
                        } while  currentDataSize < bytesOFData
                        
                        if newData.data(using: .utf8)!.count > 504 {
                            let splitData = splitString(str: newData, threshold: 504)
                            disk[fileDestination].file?.user_data = splitData.0
                            disk[fileDestination].file?.frwd_fixed = m_head_free_list
                            let newDataBlock = DataFile(back_fixed: fileDestination, frwd_fixed: 0, user_data: splitData.1, mode: "O")
                            disk[m_head_free_list].file = newDataBlock
                            m_head_free_list += 1
                        }
                        else {
                            disk[fileDestination].file?.user_data = newData
                        }
                    }
                }
            }
            // prints appropriate message if file is not in the correct mode
            else {
                print("File is not in O or U mode")
            }
        }
    }
}

// Name: Close - Function to close file. This function closes the last opened or created file
func closeFile() {
    var filePathArr = lastCreatedFileName.components(separatedBy: "/")
    var diskIndex = 0;
    let fileName = filePathArr.removeLast()
    // get the block number for the directory the file resides in
    for i in 0..<filePathArr.count {
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
    }
    // loop through directories to get the file
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == fileName {
            // gets the block number of file from directory entries
            let fileDestination = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            // sets mode of file to "C" for closed
            disk[fileDestination].file?.mode = "C"
        }
    }
}

// Name: openFile - Function to open file in mode O,U or I
// Parameters: mode: indicates the mode the file needs to be opened in, filePath: indicates the path of file in file system
func openFile(mode: String, filePath: String) {
    var filePathArr = filePath.components(separatedBy: "/")
    var diskIndex = 0;
    let fileName = filePathArr.removeLast()
    // get the block number for directory the file is in
    for i in 0..<filePathArr.count {
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
        if diskIndex == -1 {
            print("\(filePathArr[i]) not created")
            return
        }
    }
    // loop through directory to get the block number for file
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == fileName {
            let fileDestination = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            // set the mode of file the mode passed in input
             disk[fileDestination].file?.mode = Character(mode)
             lastCreatedFileName = filePath
        }
    }
}

//deleteFile -  function to delete a file
//Parameter: FilePath: indicates the path of file in file system
func deleteFile(filePath: String){
    var filePathArr = filePath.components(separatedBy: "/")
    var diskIndex = 0;
    let deleteItemName = filePathArr.removeLast()
    // get the block number of directory file is in
    for i in 0..<filePathArr.count {
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: filePathArr[i])
    }
    // loop through directory entries to find file
    for i in 0..<disk[diskIndex].directory!.directoryEntries.count {
        if disk[diskIndex].directory!.directoryEntries[i].name == deleteItemName {
            
            // get the block number of file on disk
            let indexOfDeleteItem = disk[diskIndex].directory!.directoryEntries[i].link_fixed
            let next = disk[indexOfDeleteItem].next
            let prev = disk[indexOfDeleteItem].prev
            var sector = Sector(directory: nil, file: nil)
            sector.next = next
            sector.prev = prev
            // delete the sector object from the disk array
            disk.remove(at: indexOfDeleteItem)
            // insert an empty object of type sector in the same location
            disk.insert(sector, at: indexOfDeleteItem)
            
            let newEntry = DirectoryEntry()
            // remove the entry of file from directory entries in the parent directory
            disk[diskIndex].directory?.directoryEntries.remove(at: i)
            disk[diskIndex].directory!.directoryEntries.insert(newEntry, at: i)
            numberOfFiles -= 1
        }
    }
}

//Name: createFileOrDir - function to create a file or directory
// Parameters: type: Indicates if its a file or directory, filePath: indicates the path of file in file system
func createFileOrDir(type: String, filePath: String) {
    let filePathArr = filePath.components(separatedBy: "/")
    // check if the file or dir is being created in root
    if filePathArr.count == 1   {
        if type == "D" {
            // get the free
            var index = getFreeIndex(directoryEntries: ( disk[0].directory?.directoryEntries)!)
            var diskLocation = 0
            
            if index == -1 {
                let nextBlock = m_head_free_list
                disk[0].directory?.frwd_fixed = nextBlock
                let dir = Directory(blockNumber: nextBlock , back_fixed: 0, frwd_fixed: 0, free_fixed: nextBlock + 1, directoryEntries: createDirectoryEntries())
                m_head_free_list += 1
                disk[nextBlock].directory = dir
                index = getFreeIndex(directoryEntries: (disk[nextBlock].directory?.directoryEntries)!)
                diskLocation = nextBlock
            }
            
            disk[diskLocation].directory?.directoryEntries[index].type = "D"
            disk[diskLocation].directory?.directoryEntries[index].name = filePathArr[0]
            disk[diskLocation].directory?.directoryEntries[index].link_fixed = m_head_free_list
            
            let dir = Directory(blockNumber: ( disk[diskLocation].directory?.free_fixed)!, back_fixed: ( disk[diskLocation].directory?.blockNumber)!, frwd_fixed: 0, free_fixed: m_head_free_list + 1, directoryEntries: createDirectoryEntries())
            
            disk[m_head_free_list].directory = dir
            numberOfDir += 1
            m_head_free_list += 1
        }
        else if type == "U" {
            var diskLocation = 0
            let fileExists = checkFileExists(path: filePathArr)
            if fileExists.fileExists == false {
                var index = getFreeIndex(directoryEntries: ( disk[0].directory?.directoryEntries)!)
                
                if index == -1 {
                    let nextBlock = m_head_free_list
                    disk[0].directory?.frwd_fixed = nextBlock
                    let dir = Directory(blockNumber: nextBlock , back_fixed: 0, frwd_fixed: 0, free_fixed: nextBlock + 1, directoryEntries: createDirectoryEntries())
                    m_head_free_list += 1
                    disk[nextBlock].directory = dir
                    index = getFreeIndex(directoryEntries: (disk[nextBlock].directory?.directoryEntries)!)
                    diskLocation = nextBlock
                }
                
                var newEntry =  disk[diskLocation].directory?.directoryEntries[index]
                disk[diskLocation].directory?.directoryEntries.remove(at: index)
                newEntry?.type = "U"
                newEntry?.name = filePathArr[0]
                newEntry?.link_fixed = m_head_free_list
                disk[diskLocation].directory?.directoryEntries.insert(newEntry!, at: index)
                
                let datafile = DataFile(back_fixed: 0, frwd_fixed: 0, user_data: "", mode: "O")
                disk[m_head_free_list].file = datafile
                
                lastCreatedFileName = filePath
                numberOfFiles += 1
                m_head_free_list += 1
            }
            else {
                let datafile = DataFile(back_fixed: 0, frwd_fixed: 0, user_data: "reInserted", mode: "O")
                disk[fileExists.index].file = datafile
            }
        }
    }
    else {
        var filePathArr = filePath.components(separatedBy: "/")
        let newItemName = filePathArr.removeLast()
        let finalLocation = getPathIndex(path: filePathArr)
        var index = 0
        if type == "D" {
            
            index = getFreeIndex(directoryEntries: ( disk[finalLocation].directory?.directoryEntries)!)

            disk[finalLocation].directory?.directoryEntries[index].type = "D"
            disk[finalLocation].directory?.directoryEntries[index].name = newItemName
            disk[finalLocation].directory?.directoryEntries[index].link_fixed = m_head_free_list
            
            let dir = Directory(blockNumber: ( disk[finalLocation].directory?.free_fixed)!, back_fixed: ( disk[finalLocation].directory?.blockNumber)!, frwd_fixed: 0, free_fixed: m_head_free_list + 1, directoryEntries: createDirectoryEntries())
            
            disk[m_head_free_list].directory = dir
            numberOfDir += 1
            m_head_free_list += 1
        }
        else if type == "U" {
            
            let path = filePath.components(separatedBy: "/")
            let fileExists = checkFileExists(path: path)
            if fileExists.fileExists == false {
                
                let index = getFreeIndex(directoryEntries: ( disk[finalLocation].directory?.directoryEntries)!)
                var newEntry =  disk[finalLocation].directory?.directoryEntries[index]
                disk[finalLocation].directory?.directoryEntries.remove(at: index)
                newEntry?.type = "U"
                newEntry?.name = newItemName
                newEntry?.link_fixed = m_head_free_list
                disk[finalLocation].directory?.directoryEntries.insert(newEntry!, at: index)
                
                let datafile = DataFile(back_fixed: 0, frwd_fixed: 0, user_data: "", mode: "O")
                disk[m_head_free_list].file = datafile
                
                lastCreatedFileName = filePath
                numberOfFiles += 1
                m_head_free_list += 1
            }
            else {
                let datafile = DataFile(back_fixed: 0, frwd_fixed: 0, user_data: "reInserted", mode: "O")
                disk[fileExists.index].file = datafile
            }
        }
    }
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
        Dwrite(commandType: "Create", type: type, filePath: name, numberOfBytes: nil)
    case "DELETE":
        Dwrite(commandType: "Delete",type: type, filePath: name, numberOfBytes: nil)
    case "OPEN":
        Dread(commandType: "Open",type: type, filePath: name, numberOfBytes: nil)
    case "CLOSE":
        Dread(commandType: "Close",type: type, filePath: name, numberOfBytes: nil)
    case "WRITE":
        Dwrite(commandType: "Write",type: nil, filePath: name, numberOfBytes: Int(type))
    case "READ":
        Dread(commandType: "Read", type: nil, filePath: lastCreatedFileName, numberOfBytes: Int(name))
    case "SEEK":
        Dread(commandType: "Seek", type: type, filePath: lastCreatedFileName, numberOfBytes: Int(name))
    default:
        print("Defualt")
    }
    
    if commandType == "CREATE" { print("Path: \(name)")}
    print("Number of Directories: \(numberOfDir)")
    print("Number of user files: \(numberOfFiles)")
    print("Number of free block:\(MAX_DISK_SPACE - m_head_free_list)")
}

// Name: createDirectoryEntries - function to create an array of size 31 of directory entries
func createDirectoryEntries() -> [DirectoryEntry] {
    var count = 0
    var directoryEntries = [DirectoryEntry]()
    while count < 31 {
        let entry = DirectoryEntry()
        directoryEntries.append(entry)
        count += 1
    }
    return directoryEntries
}

//Name: getFreeIndex - function returns the next available index in directory entries
func getFreeIndex(directoryEntries: [DirectoryEntry]) -> Int {
    
    for i in 0..<directoryEntries.count {
        if directoryEntries[i].type == "F" { return i }
    }
    return -1
}

//Name: getPathIndex - function goes through the path and returns the parent directory the file or directory being accessed
func getPathIndex(path: [String]) -> Int {
    var diskIndex = 0;
    
    for i in 0..<path.count {
        // starts looking in root dir entries for the file or directory
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: path[i])
        // if not found checks if root has a forward bin
        if diskIndex == -1 {
            diskIndex = 0
            let nextLocation = disk[diskIndex].directory?.frwd_fixed
            diskIndex = getDiskLocationForItem(directoryEnteries: (disk[nextLocation!].directory?.directoryEntries)!, itemName: path[i])
        }
    }
    return diskIndex
}

func getDiskLocationForItem(directoryEnteries: [DirectoryEntry], itemName: String) -> Int {
    for i in 0..<directoryEnteries.count {
        if directoryEnteries[i].name == itemName { return directoryEnteries[i].link_fixed }
    }
    return -1
}

//Name: checkFileExists - function checks if file exists and returns a bool and the disk location of file
func checkFileExists(path: [String]) -> (fileExists: Bool, index: Int) {
    var diskIndex = 0;
    for i in 0..<path.count {
        diskIndex = getDiskLocationForItem(directoryEnteries: (disk[diskIndex].directory?.directoryEntries)!, itemName: path[i])
    }
    if diskIndex != -1
        { return(true, diskIndex) }
    else
        {  return (false, -1) }
}

//Name: splitString - function splits the string based on the number of bytes and returns the string and excess
func splitString(str: String, threshold: Int) -> (String, String) {
    var count = 0
    var allowedString = ""
    var excessString = ""
    if str.count < threshold {
        allowedString = str
    }
    else {
        for c in str {
            if count < threshold {
                count+=1
                allowedString.append(c)
            } else {
                excessString.append(c)
            }
        }
    }
    return (allowedString, excessString)
}

initializeList()
createRootDirectory()
getCommand()
print("Enter Y to continue")
let cont = readLine()
while cont != "N" {
getCommand()
}


