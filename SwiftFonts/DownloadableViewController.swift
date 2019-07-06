import UIKit

class DownloadableViewController: BaseFontViewController {

    required init?(coder: NSCoder) {

        super.init(coder: coder)

        let tempFonts = DownloadableFontsCodeGenerator.shared.listOfFontsByFamily()
        super.familyNames = tempFonts.keys.sorted()
        super.fonts = tempFonts
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        let alert = UIAlertController(title: "WARNING", message: "Fonts are loaded as you scroll. Tap a cell to reload it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
