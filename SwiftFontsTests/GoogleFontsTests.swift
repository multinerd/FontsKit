import XCTest
@testable import SwiftFonts

class GoogleFontsTests: XCTestCase {

    let generator = GoogleFontsCodeGenerator.shared
        
    func test() {
        XCTAssertNotNil(generator)
    }
    
    
}
