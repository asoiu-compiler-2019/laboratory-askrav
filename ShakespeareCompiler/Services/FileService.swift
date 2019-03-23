//
//  FileService.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

class FileService {
    
    static var outputFilePath: String = FileManager.default.currentDirectoryPath.appending("/result.cpp")
    
    static func loadSrc() {
        let filename = "hello_world.txt"
        let dir = FileManager.default.currentDirectoryPath
        let programFilePath = dir.appending("/\(filename)")
        
        let seq = try! String(contentsOfFile: programFilePath).split(separator: "\n")
        sourceCode = seq.map { String($0) }
    }
    
    static func loadWordLists() {
        loadFileIntoList("resources/neutral_adjective.wordlist" , &Adjectives.positive)
        loadFileIntoList("resources/positive_adjective.wordlist", &Adjectives.positive)
        loadFileIntoList("resources/negative_adjective.wordlist", &Adjectives.negative)
        loadFileIntoList("resources/positive_noun.wordlist", &Nouns.positive)
        loadFileIntoList("resources/neutral_noun.wordlist" , &Nouns.positive)
        loadFileIntoList("resources/negative_noun.wordlist", &Nouns.negative)
        loadFileIntoList("resources/positive_comparative.wordlist", &Comparatives.positive)
        loadFileIntoList("resources/positive_comparative.wordlist", &Comparatives.negative)
        loadFileIntoList("resources/character.wordlist", &Names.valid)
    }
    
    static func writeToFile(_ s: String) {
        var str = s
        do {
            if let existingString = try? String(contentsOfFile: outputFilePath, encoding: .utf8) {
                str = existingString + "\n" + str
            }
            try str.write(toFile: outputFilePath, atomically: false, encoding: .utf8)
        } catch {
            assert(false, error.localizedDescription)
        }
    }
    
    static func writeScenes(scenes: [String], isLast: Bool) {
        writeToFile("act" + String(ActInfo.actnum) + ": {\ngoto act_" + String(ActInfo.actnum) + "_scene1;\n}")
        
        for j in 0..<scenes.count {
            writeToFile("act_" + String(ActInfo.actnum) + "_scene" + String(j + 1) + ": {")
            writeToFile(scenes[j])
            
            if j < scenes.count - 1 {
                writeToFile("goto act_" + String(ActInfo.actnum) + "_scene" + String(j + 2) + ";\n")
            } else if !isLast {
                writeToFile("goto act" + String(ActInfo.actnum + 1) + ";\n")
            }
            
            writeToFile("}")
        }
    }
    
    static func writeInitialInfo() {
        clearFile()
        writeToFile(
            "#include <stdio.h>\n" +
            "#include <math.h>\n" +
            "#include \"resources/mathhelpers.h\"\n" +
            "int condition = 0;\n" +
            "char inputbuffer[BUFSIZ];\n" +
            "int main() {\n"
        )
    }
    
    private static func clearFile() {
        try? "".write(toFile: outputFilePath, atomically: false, encoding: .utf8)
    }
    
    private static func loadFileIntoList(_ filename: String, _ list: inout [String]) {
        let dir = FileManager.default.currentDirectoryPath
        let programFilePath = dir.appending("/\(filename)")
        
        let seq = try! String(contentsOfFile: programFilePath).split(separator: "\n")
        
        list.append(contentsOf: seq.map { String($0) })
    }
}
