import UIKit

class PreinstalledViewController: BaseFontViewController {

    required init?(coder: NSCoder) {

        super.init(coder: coder)

        let tempFonts = PreinstalledFontsCodeGenerator.shared.listOfFontsByFamily()
        super.familyNames = tempFonts.keys.sorted()
        super.fonts = tempFonts
    }
}

