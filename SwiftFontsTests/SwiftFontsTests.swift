import XCTest
import SwiftFonts

class SwiftFontsTests: XCTestCase {

	let generator = PreinstalledFontsCodeGenerator.shared

	let fontName = "Typewriter"

	// MARK: - Debugger

	/// Generate code to debugger
	func test_toDebugger() {

		generator.generateCodeToDebugger()
	}

	// MARK: - Full

	/// Generate all fonts to file
	func test_full_all() {

		generator.generateCode(filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/PreinstalledFonts.swift")
	}

	/// Generate some font to file
	func test_full_some() {

		generator.generateCode(named: fontName, filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/PreinstalledFonts.swift")
	}

	// MARK: - Individual

	/// Generate all fonts to individual file
	func test_individual_all() {

		generator.generateCode(directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
	}

	/// Generate some font to individual file
	func test_individual_some() {

		generator.generateCode(named: fontName, directoryPath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/iOSFonts/")
	}
}
