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
    
    let generator = iOSGenerator.shared
    
    let fontName = "Typewriter"
    
    // MARK: - Debugger
    
    func test_toDebugger() {
        generator.generateCodeToDebugger()
    }
    
    
    // MARK: - Full
    
    func test_full_all() {
        generator.generateCode(filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSGenerated.swift")
    }
    
    func test_full_some() {
        generator.generateCode(named: fontName, filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSGenerated.swift")
    }
    
    // MARK: - Individual
    
    func test_individual_all() {
        generator.generateCode(directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
    }
    
    func test_individual_some() {
        generator.generateCode(named: fontName, directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
    }
    
    
}
