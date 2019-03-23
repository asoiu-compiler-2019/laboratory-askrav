//
//  GlobalVars.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

struct Adjectives {
    static var positive: [String] = []
    static var negative: [String] = []
}

struct Comparatives {
    static var positive: [String] = []
    static var negative: [String] = []
}

struct Nouns {
    static var positive: [String] = []
    static var negative: [String] = []
    static var neutral: [String] = ["nothing", "zero"]
}

struct Names {
    static var valid: [String] = []
}

struct Operators {
    static var binary = ["sum", "difference", "quotient", "product"]
    static var unary  = ["square", "cube", "twice"]
}

struct StageInfo {
    static var speaker = ""
    static var target = ""
    static var stageActors: [String] = []
}

struct ActInfo {
    static var actnum = 0
    static var actNames: [String: Int] = [:]
}

struct SceneInfo {
    static var sceneNames: [[String: Int]] = []
}

var sourceCode: [String] = []   // Line by line
var N = 0   // Current line processing

var vartable = Set<String>()

let romanValues: [String: Int] = [
    "M": 1000, "D": 500, "C": 100, "L": 50, "X": 10, "V": 5, "I": 1
]
