import XCTest
@testable import SwiftFonts

class DownloadableFontsTests: XCTestCase {

    let generator = DownloadableFontsCodeGenerator.shared

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

        generator.generateCode(filePath: "\(codeGenDir)/DownloadableFonts.swift")
    }

    // MARK: - Testing

    func test_downloadableFontsNames() {

        let installedFonts = PreinstalledFontsCodeGenerator.shared.listOfFontNames()
        // print(installedFonts.sorted().joined(separator: "\n"))
        // print("\(installedFonts.count) installed fonts")

        // printDivider()
        let downloadableFonts = UIFont.downloadableFontNames(excludeInstalled: true)
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

