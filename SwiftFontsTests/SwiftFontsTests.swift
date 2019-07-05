//
//  SwiftFontsTests.swift
//  SwiftFontsTests
//
//  Created by Josh Brown on 6/3/14.
//  Copyright (c) 2014 Roadfire Software. All rights reserved.
//

import XCTest
import SwiftFonts

class SwiftFontsTests: XCTestCase {
    
    func test_toDebugger() {
        iOSGenerator.generateCodeToDebugger()
    }
    
    func test_full() {
        iOSGenerator.generateCode(filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSGenerated.swift")
    }
    
    func test_individual() {
        iOSGenerator.generateCode(directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/")
    }
}
