//
//  Node.swift
//  ShakespeareCompiler
//
//  Created by Inquisitor on 3/16/19.
//  Copyright © 2019 Alexander Kravchenko. All rights reserved.
//

import Foundation

class Node {
    
    var value: String
    var left: Node?
    var right: Node?
    
    init(v: String, l: Node?, r: Node?) {
        self.value = v
        self.left = l
        self.right = r
    }
}
