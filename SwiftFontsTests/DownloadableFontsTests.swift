import XCTest
@testable import SwiftFonts

class DownloadableFontsTests: XCTestCase {

    let generator = DownloadableFontsCodeGenerator.shared
    
    func test() {
        XCTAssertNotNil(generator)
    }

    /// Generate all fonts to file
    func test_full_all() {
        
        generator.generateCode(filePath: "/Users/multinerd/Documents/_Fonts/Swiftly-Font/SwiftFonts/Sources/CodeGen/DownloadableFonts.swift")

    }
        
        
        
    
    func test_downloadableFontsNames() {
        
        let installedFonts = PreinstalledFontsCodeGenerator.shared.listOfFontNames()
        // print(installedFonts.sorted().joined(separator: "\n"))
        // print("\(installedFonts.count) installed fonts")
        
        // printDivider()
        let downloadableFonts = generator.listOfFontNames(excludeInstalled: true)
        print(downloadableFonts.sorted().joined(separator: "\n"))
        // print("\(downloadableFonts.count) downloadable fonts")
        
        // printDivider()
        let notInstalled = Array(Set(downloadableFonts).subtracting(installedFonts))
        // print(notInstalled.sorted().joined(separator: "\n"))
        // print("\(notInstalled.count) not installed and downloadable")
        
        // printDivider()
        let alreadyInstalled = Array(Set(downloadableFonts).symmetricDifference(Set(notInstalled)))
        // print(alreadyInstalled.sorted().joined(separator: "\n"))
        // print("\(alreadyInstalled.count) already installed and downloadble")
        
        assert(downloadableFonts.count == notInstalled.count)
        assert(alreadyInstalled.count == 0)
    }
        
    func printDivider() {
        print("\n------------------------------------\n")
    }
}
