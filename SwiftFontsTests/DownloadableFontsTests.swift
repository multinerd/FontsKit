import XCTest
@testable import SwiftFonts

class DownloadableFontsTests: XCTestCase {

    let generator = DownloadableFontsCodeGenerator.shared
    
    func test() {
        XCTAssertNotNil(generator)
    }
    
}
