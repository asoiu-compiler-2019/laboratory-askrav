//
//  String+Ext.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

extension String {
    
    func trimmed() -> String {
        var trimmed = ""
        for char in self {
            if !["\t", "\r", "\n", " "].contains(char) {
                trimmed.append(char)
            }
        }
        return trimmed
    }
    
    func trimmedLeadingWhitespace() -> String {
        var trimIndex = 0
        
        for char in self {
            if ["\t", "\r", "\n", " "].contains(char) {
                trimIndex += 1
            } else {
                break
            }
        }
        
        var str = self
        str.removeFirst(trimIndex)
        return str
    }
    
    subscript(index: Int) -> String {
        get {
            let _ind = self.index(self.startIndex, offsetBy: index)
            return String(self[_ind])
        }
        set {
            assert(false)
        }
    }
    
    func find(_ char: Character) -> Int {
        guard let index = self.firstIndex(of: char) else { return -1 }
        return self.distance(from: self.startIndex, to: index)
    }
    
    func removedLast(_ n: Int) -> String {
        var str = self
        str.removeLast(n)
        return str
    }
    
    func removedFirst(_ n: Int) -> String {
        var str = self
        str.removeFirst(n)
        return str
    }
    
    func first(_ n: Int) -> String {
        var res = ""
        for i in 0..<n { res.append(self[i]) }
        return res
    }
}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}


func startsWithTrimWhitespace(_ str: String, substring: String) -> Bool {
    return startsWith(str.trimmed(), substring: substring)
}

func startsWith(_ str: String, substring: String) -> Bool {
    return str.starts(with: substring)
}

func concatWords(wordArray: [String]) -> String {
//    return wordArray.reduce("", { $0 + $1 })
    var c = ""
    for word in wordArray {
        c += word
    }
    return c
}
