import XCTest
@testable import SwiftFonts

class PreinstalledFontsTests: XCTestCase {

    let generator = PreinstalledFontsCodeGenerator.shared

    // MARK: - Generic Tests

    func test() {

        XCTAssertNotNil(generator)
    }

    func test_listByFamily() {

        let results = generator.listOfFontsByFamily()
        print(results)
        XCTAssertNotNil(results)
    }

    // MARK: - Code Gen

    func test_codeGen() {

        generator.generateCode(filePath: "\(codeGenDir)/PreinstalledFonts.swift")
    }

    // MARK: - Testing

    let fontName = "Typewriter"

    // MARK: Debugger

    /// Generate code to debugger
    func test_toDebugger() {

        generator.generateCodeToDebugger()
    }

    // MARK: Full

    /// Generate all fonts to file
    func test_full_all() {

        generator.generateCode(filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/PreinstalledFonts.swift")
    }

    /// Generate some font to file
    func test_full_some() {

        generator.generateCode(named: fontName, filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/PreinstalledFonts.swift")
    }

    // MARK: Individual

    /// Generate all fonts to individual file
    func test_individual_all() {

        generator.generateCode(directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
    }

    /// Generate some font to individual file
    func test_individual_some() {

        generator.generateCode(named: fontName, directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
    }
}
