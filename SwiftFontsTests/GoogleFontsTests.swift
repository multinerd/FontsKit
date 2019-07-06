import XCTest
@testable import SwiftFonts

class GoogleFontsTests: XCTestCase {

    let generator = GoogleFontsCodeGenerator.shared
    
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
        
        generator.generateCode(filePath: "\(codeGenDir)/GoogleFonts.swift")
    }
}
