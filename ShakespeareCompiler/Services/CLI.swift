//
//  CLI.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

class CLI {
    
    static func launchCompiled() {
        bash("g++", arguments: ["result.cpp"])
        let result = bash("./a.out", arguments: [])
        print(result)
    }
    
    private static func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.count > 0 {
            let lastIndex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIndex])
        }
        return output
    }
    
    @discardableResult
    private static func bash(_ command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(launchPath: whichPathForCommand, arguments: arguments)
    }
}
