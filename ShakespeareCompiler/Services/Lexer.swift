//
//  Lexer.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

func isNoun(_ word: String) -> Bool {
    return Nouns.positive.contains(word) ||
        Nouns.negative.contains(word) ||
        Nouns.neutral.contains(word)
}

func isAdjective(_ word: String) -> Bool {
    return Adjectives.positive.contains(word) ||
        Adjectives.negative.contains(word)
}

func isComparative(_ word: String) -> Bool {
    return Comparatives.positive.contains(word) ||
        Comparatives.negative.contains(word)
}

func nounValue(_ word: String) -> Int {
    assert(isNoun(word), "Tried to find the nounvalue of a non-noun")
    if Nouns.positive.contains(word) { return 1 }
    if Nouns.negative.contains(word) { return -1 }
    return 0
}

func isNumber(_ str: String) -> Bool {
    let words = str.components(separatedBy: " ")
    for word in words {
        if isNoun(word) { return true }
    }
    return false
}

func handleDeclarations() {
    var declarations: [String] = []
    var unfinished = false
    
    while !startsWithTrimWhitespace(sourceCode[N], substring: "Act") {
        assert(N < sourceCode.count - 1, "File contains no Acts")
        
        if sourceCode[N].trimmed().count > 0 {
            if !unfinished {
                declarations.append(sourceCode[N])
            } else {
                declarations[declarations.count - 1] += sourceCode[N]
            }
            
            unfinished = sourceCode[N].index(of: ".") == nil
        }
        
        N += 1
    }
    
    for dec in declarations {
        let commaIndex = dec.find(",")
        assert(commaIndex > 0, "Improper declaration")
        
        let wordsInName = dec.first(commaIndex).trimmedLeadingWhitespace().components(separatedBy: " ")
        
        let varname = wordsInName.last!
        let value = parseNum(dec.removedFirst(commaIndex).removedLast(2), failOk: true)
        
        FileService.writeToFile("int " + String(varname) + " = " + String(value) + ";")
        assert(Names.valid.contains(varname), "Non-Shakespearean variable name")
        vartable.insert(varname)
    }
}

func getActOrScene(_ s: String, actOrScene: String) -> Int {
    var num = String(s[s.index(of: actOrScene)!...]).components(separatedBy: " ")[1]
    
    if num.find(":") > 0 {
        num = num.first(num.find(":"))
    } else {
        assert(false, ("Bad " + actOrScene + " heading"))
    }
    
    return calculateRomanSum(num)
}

func getActOrSceneDescription(_ s: String) -> String {
    let k = s.find(":") + 1
    var desc = s.removedFirst(k).trimmed().lowercased()
    let p = findPunctuation(desc)
    
    if p > 0 {
        desc = desc.first(p)
    }
    
    return desc
}

func parseAllActAndSceneDescriptions() {
    var currentAct = 0
    var currentScene = 0
    SceneInfo.sceneNames = [[:]]
    
    for line in sourceCode {
        if startsWithTrimWhitespace(line, substring: "Act") {
            let desc = getActOrSceneDescription(line)
            currentAct += 1
            ActInfo.actNames[desc] = currentAct
            SceneInfo.sceneNames.append([:])
        } else if startsWithTrimWhitespace(line, substring: "Scene") {
            let desc = getActOrSceneDescription(line)
            currentScene += 1
            SceneInfo.sceneNames[currentAct][desc] = currentScene
        }
    }
}

func parseNum(_ str: String, failOk: Bool = false) -> Int {
    let words = str.split(separator: " ")
    var nounIndex = words.count
    
    for i in 0..<words.count {
        if isNoun(String(words[i])) {
            nounIndex = i
            break
        }
    }
    
    let ok = nounIndex < words.count
    if !ok && failOk { return 0 }
    assert(ok, "\(str) supposed to be a number (noun)")
    
    var value = nounValue(String(words[nounIndex]))
    
    for word in words[0..<nounIndex] {
        if isAdjective(String(word)) {
            value *= 2
        }
    }
    
    return value
}

func parseNames(_ str: String) -> [String] {
    var str = str
    
    guard let spaceIndex = str.firstIndex(of: " ") else {
        assert(false, "Parsing error")
    }
    
    str = String(str[spaceIndex..<str.endIndex])
    _ = str.removeFirst()
    var names = str.split(separator: " ").map { String($0) }
    if let andIndex = names.firstIndex(of: "and") { names.remove(at: andIndex) }
    
    return names
}
