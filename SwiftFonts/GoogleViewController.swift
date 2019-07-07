import UIKit

class GoogleViewController: BaseFontViewController {
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        let tempFonts = GoogleFontsCodeGenerator.shared.listOfFontsByFamily()
        super.familyNames = tempFonts.keys.sorted()
        super.fonts = tempFonts
    }
    
}
