//
//  Parser.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

func wordToOperator(_ op: String) -> String {
    switch op {
    case "sum": return "+"
    case "difference": return "-"
    case "quotient": return "/"
    case "product": return "*"
    default: assert(false, "Illegal operator")
    }
}

func buildExpressionTree(expr: [String]) -> (Node, [String]) {
    var expr = expr
    assert(expr.count > 0, "Illegal expression")
    
    if expr[0] == "square" {
        if expr[1] == "root" {
            let op = "(int)sqrt"
            expr = Array(expr[2...])
            let num: Node
            (num, expr) = buildExpressionTree(expr: expr)
            return (Node(v: op, l: num, r: nil), expr)
        }
    } else if expr[0] == "remainder" {
        if expr[1] == "of" && expr[2] == "the" && expr[3] == "quotient" {
            expr = Array(expr[4...])
            let op = "%"
            let left, right: Node
            (left, expr) = buildExpressionTree(expr: expr)
            (right, expr) = buildExpressionTree(expr: expr)
            return (Node(v: op, l: left, r: right), expr)
        }
    }
    
    if Operators.binary.contains(expr[0]) {
        let op = wordToOperator(expr[0])
        expr = Array(expr[1...])
        let left, right: Node
        (left, expr) = buildExpressionTree(expr: expr)
        (right, expr) = buildExpressionTree(expr: expr)
        return (Node(v: op, l: left, r: right), expr)
    } else if Operators.unary.contains(expr[0]) {
        let op = expr[0]
        expr = Array(expr[1...])
        let num: Node
        (num, expr) = buildExpressionTree(expr: expr)
        return (Node(v: op, l: num, r: nil), expr)
    }
    
    if true {
        var i = expr[0] == "and" ? 1 : 0
        var numstr = ""
        
        while !Operators.binary.contains(expr[i]) && !Operators.unary.contains(expr[i]) && !["and", "remainder"].contains(expr[i]) {
            if ["you", "thee", "yourself", "thyself", "thou"].contains(expr[i]) {
                expr = Array(expr[(i+1)...])
                return (Node(v: StageInfo.target, l: nil, r: nil), expr)
            } else if ["me", "myself", "i"].contains(expr[i]) {
                expr = Array(expr[(i+1)...])
                return (Node(v: StageInfo.speaker, l: nil, r: nil), expr)
            } else if vartable.contains(expr[i].capitalized) {
                let name = expr[i]
                expr = Array(expr[(i+1)...])
                return (Node(v: name.capitalized, l: nil, r: nil), expr)
            } else if i == (expr.count - 1) {
                numstr += expr[i]
                i = expr.count
                break
            } else {
                numstr += (expr[i] + " ")
                i += 1
            }
        }
        
        if i == expr.count {
            expr = []
        } else {
            expr = Array(expr[i...])
        }
        
        if !isNumber(numstr) {
            return buildExpressionTree(expr: expr)
        } else {
            return (Node(v: "\(parseNum(numstr))", l: nil, r: nil), expr)
        }
    }
}

func treeToString(_ tree: Node) -> String {
    if tree.left == nil {
        // value only
        return tree.value
    } else if tree.right == nil {
        // unary operator
        return tree.value + "(" + treeToString(tree.left!) + ")"
    } else {
        // binary operator
        return "(" + treeToString(tree.left!) + " " + tree.value + " " + treeToString(tree.right!) + ")"
    }
}

func parseExpr(_ expr: String) -> String {
    let e = expr.components(separatedBy: " ")
    let tree = buildExpressionTree(expr: e).0
    return treeToString(tree)
}

func getStatements() -> [String] {
    var statements: [String] = []
    var line = sourceCode[N].trimmedLeadingWhitespace()
    var unfinished = false
    
    while line.find(":") < 0 && line.find("[") < 0 {
        let punctuation = findPunctuation(line)
        
        if punctuation < 0 {
            if !unfinished {
                statements.append(line)
            } else {
                let lastIndex = statements.count - 1
                statements[lastIndex] += line
            }
            
            N += 1
            line = sourceCode[N]
            unfinished = true
        } else if punctuation > 0 {
            if !unfinished {
                statements.append("")
            }
            
            let lastIndex = statements.count - 1
            statements[lastIndex] += line.first(punctuation)
            line = line.removedFirst(punctuation + 1)
            unfinished = false
        }
    }
    
    var retval: [String] = []
    for stat in statements {
        if stat.trimmed().count > 0 {
            retval.append(stat)
        }
    }
    
    return retval
}

func parseEnterOrExit() {
    
    guard let startBracket = sourceCode[N].firstIndex(of: "["),
        let endBracket = sourceCode[N].firstIndex(of: "]") else {
            assert(false, "Enter of exit sould match [ %s ] pattern")
    }
    
    var enterOrExit = String(sourceCode[N][startBracket..<endBracket])
    _ = enterOrExit.removeFirst()
    
    if startsWithTrimWhitespace(enterOrExit, substring: "Enter") {
        
        let names = parseNames(enterOrExit)
        
        for name in names {
            assert(vartable.contains(name), "Undeclared actor entering a scene")
            StageInfo.stageActors.append(name)
        }
        
        assert(StageInfo.stageActors.count < 3, "Too many actors on stage")
    } else if startsWithTrimWhitespace(enterOrExit, substring: "Exit") {
        
        let names = parseNames(enterOrExit)
        
        for name in names {
            assert(StageInfo.stageActors.contains(name), "Trying to make an actor who is not in the scene exit")
            let index = StageInfo.stageActors.firstIndex(of: name)!
            StageInfo.stageActors.remove(at: index)
        }
    } else if startsWithTrimWhitespace(enterOrExit, substring: "Exeunt") {
        StageInfo.stageActors.removeAll()
    }
}

func calculateRomanSum(_ str: String) -> Int {
    let romanString = str.uppercased()
    var strIndex = 0
    var romanSum = 0
    
    while strIndex < (romanString.count - 1) {
        
        let currentValue = romanValues[romanString[strIndex]]!
        let nextValue = romanValues[romanString[strIndex + 1]]!
        
        if currentValue < nextValue {
            romanSum -= currentValue
        } else {
            romanSum += currentValue
        }
        
        strIndex += 1
    }
    
    let currentValue = romanValues[romanString[strIndex]]!
    
    return romanSum + currentValue
}

func findPunctuation(_ str: String) -> Int {
    let indexes = [str.firstIndex(of: "."),
                   str.firstIndex(of: "!"),
                   str.firstIndex(of: "?")]
        .compactMap { $0 }
        .compactMap { str.distance(from: str.startIndex, to: $0) }
    
    return indexes.min() ?? -1
}
