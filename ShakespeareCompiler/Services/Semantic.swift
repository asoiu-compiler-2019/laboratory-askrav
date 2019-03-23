//
//  Semantic.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

func parseStatement(stat: String) -> String {
    let statement = stat.trimmedLeadingWhitespace().lowercased()
    let first = statement.components(separatedBy: " ")[0]
    let trimmed = statement.trimmed()
    
    if ["you", "thou"].contains(first) {
        var expr = ""
        if let lastIndex = statement.indexes(of: " as ").last {
            let ind = statement.index(lastIndex, offsetBy: 4)
            expr = String(statement[ind...])
        } else {
            let ind = statement.index(statement.startIndex, offsetBy: first.count + 1)
            expr = String(statement[ind...])
        }
        
        return StageInfo.target + " = " + parseExpr(expr) + " ;\n"
    } else if trimmed == "openyourheart" || trimmed == "openthyheart" {
        return "fprintf(stdout, \"%d\", \(StageInfo.target));\n"
    } else if trimmed == "speakyourmind" || trimmed == "speakthymind" {
        return "fprintf(stdout, \"%c\", (char)\(StageInfo.target));\n"
    } else if trimmed == "listentoyourheart" || trimmed == "listentothyheart" {
        return "fgets(inputbuffer, BUFSIZ, stdin);\nsscanf(inputbuffer, \"%d\", &\(StageInfo.target));\n"
    } else if trimmed == "openyourmind" || trimmed == "openyourmind" {
        return StageInfo.target + " = getchar();\n"
    } else if ["am", "are", "art", "be", "is"].contains(first) {
        var left = ""
        var kind = ""
        var right = ""
        
        if let _ = statement.index(of: "as") {
            let arr = statement.components(separatedBy: " as ")
            left = arr[0]
            kind = arr[1]
            right = arr[2]
            assert(isAdjective(kind), "Ill-formed conditional")
            kind = "equal"
        } else if let _ = statement.index(of: "more") {
            var words = statement.components(separatedBy: " ")
            var moreloc = 0
            
            for i in 0..<words.count {
                if words[i] == "more" {
                    moreloc = i
                    break
                }
            }
            assert(isAdjective(words[moreloc + 1]), "Ill-formed conditional")
            kind = Adjectives.positive.contains(words[moreloc + 1]) ? "greater" : "lesser"
            
            let arr2 = statement.components(separatedBy: " more \(words[moreloc + 1]) ")
            left = arr2[0]
            right = arr2[1]
        } else {
            var comp = ""
            for word in statement.components(separatedBy: " ") {
                if isComparative(word) {
                    comp = word
                    break
                }
            }
            
            assert(comp.count > 0, "Ill-formed conditional")
            
            kind = Comparatives.positive.contains(comp) ? "greater" : "lesser"
            let arr2 = statement.components(separatedBy: comp)
            left = arr2[0]
            right = arr2[1]
        }
        
        var res = "=="
        if kind == "greater" { res = ">" }
        if kind == "lesser" { res = "<" }
        return "condition = (" + parseExpr(left) + ") " + res + " (" + parseExpr(right) + ");\n"
    } else if startsWith(statement, substring: "if so,") {
        let location = statement.index(of: "if so,")!
        let ind = statement.index(location, offsetBy: 7)
        let res = String(statement[ind...])
        return "if (condition) {\n " + res + " }\n"
    } else if startsWith(statement, substring: "if not,") {
        let location = statement.index(of: "if not,")!
        let ind = statement.index(location, offsetBy: 8)
        let res = String(statement[ind...])
        return "if (!condition) {\n " + res + " }\n"
    } else if startsWith(statement, substring: "let us") ||
        startsWith(statement, substring: "we shall") ||
        startsWith(statement, substring: "we must") {
        let words = statement.components(separatedBy: " ")
        let nextTwo = words[2] + " " + words[3]
        assert(nextTwo == "return to" || nextTwo == "proceed to", "Ill-formed goto")
        
        if words[4] == "scene" || words[4] == "act" {
            let typeword = words[4] == "act" ? words[4] : ("act_" + String(ActInfo.actnum) + "_scene")
            return "goto " + typeword + String(calculateRomanSum(words[5])) + ";\n"
        } else {
            let restOfPhrase = concatWords(wordArray: Array(words[4...]))
            let type_: String
            if SceneInfo.sceneNames[ActInfo.actnum].keys.contains(restOfPhrase) == true {
                type_ = "scene"
            } else if Array(ActInfo.actNames.keys).contains(restOfPhrase) {
                type_ = "act"
            } else {
                type_ = "none"
            }
            
            assert(type_ != "none", "Goto refers to nonexistant act or scene")
            
            let nameDict = type_ == "act" ? ActInfo.actNames : SceneInfo.sceneNames[ActInfo.actnum]
            
            let typeword = type_ == "act" ? type_ : ("act_" + String(ActInfo.actnum) + "_scene")
            
            return "goto " + typeword + String(nameDict[restOfPhrase]!) + ";\n"
        }
    } else {
        return ""
    }
}
