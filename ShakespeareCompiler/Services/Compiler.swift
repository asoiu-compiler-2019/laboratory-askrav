//
//  Compiler.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/2/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

class Compiler {
    
    func run() {
        FileService.loadSrc()
        FileService.loadWordLists()
        FileService.writeInitialInfo()
        
        while sourceCode[N].find(".") < 0 {
            N += 1
        }
        N += 1
        
        handleDeclarations()
        parseAllActAndSceneDescriptions()
        
        var scenes: [String] = []
        var unfinished = false
        
        while N < sourceCode.count {
            if startsWithTrimWhitespace(sourceCode[N], substring: "Act") {
                assert (getActOrScene(sourceCode[N], actOrScene: "Act") == ActInfo.actnum + 1, "Illegal Act numbering")
                
                if ActInfo.actnum > 0 {
                    FileService.writeScenes(scenes: scenes, isLast: false)
                    scenes = []
                }
                ActInfo.actnum += 1
                N += 1
            } else if startsWithTrimWhitespace(sourceCode[N], substring: "Scene") {
                assert (getActOrScene(sourceCode[N], actOrScene: "Scene") == scenes.count + 1, "Illegal Scene numbering")
                
                N += 1
                StageInfo.speaker = ""
                StageInfo.target  = ""
                
                while (N < sourceCode.count) && !(startsWithTrimWhitespace(sourceCode[N], substring: "Scene") || startsWithTrimWhitespace(sourceCode[N], substring: "Act")) {
                    if startsWithTrimWhitespace(sourceCode[N], substring: "[") {
                        parseEnterOrExit()
                        if !unfinished {
                            scenes.append(";\n")
                            unfinished = true
                        }
                        N += 1
                    } else if sourceCode[N].find(":") >= 0 {
                        let name = sourceCode[N].first(sourceCode[N].find(":")).components(separatedBy: " ").last!
                        
                        assert (StageInfo.stageActors.contains(name), "An actor who is not on stage is trying to speak")
                        
                        for actor in StageInfo.stageActors {
                            if actor != name {
                                StageInfo.target = actor
                                StageInfo.speaker = name
                            }
                        }
                        
                        N += 1
                        let statements = getStatements()
                        var scenecode = ""
                        
                        for statement in statements {
                            scenecode += parseStatement(stat: statement)
                        }
                        
                        if !unfinished {
                            scenes.append(scenecode)
                            unfinished = true
                        } else {
                            scenes[scenes.count - 1] += scenecode
                        }
                    } else {
                        N += 1
                    }
                }
                
                unfinished = false
                
            } else {
                N += 1
            }
        }
        
        FileService.writeScenes(scenes: scenes, isLast: true)
        FileService.writeToFile("}")
        
        CLI.launchCompiled()
    }
}
