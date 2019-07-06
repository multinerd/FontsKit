import UIKit

class DownloadableViewController: UITableViewController {

    var familyNames: [String] = []
    var fonts: [String: [String]] = [:]

    required init?(coder: NSCoder) {

        super.init(coder: coder)

        let unsortedFamilyNames = UIFont.downloadableFontNames() as [String]
        familyNames = unsortedFamilyNames.sorted()

        for familyName in familyNames {
            let unsortedFontNames = UIFont.fontNames(forFamilyName: familyName) as [String]
            fonts[familyName] = sortFontNames(array: unsortedFontNames)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return familyNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fonts[familyNames[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell

        let key = familyNames[indexPath.section]
        let array = fonts[key]
        let fontName = array![indexPath.row]

        cell.textLabel?.text = fontName
        cell.textLabel?.textColor = .systemGray
        cell.textLabel?.font = UIFont(name: fontName, size: UIFont.systemFontSize)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let key = familyNames[indexPath.section]
        let array = fonts[key]
        let fontName = array![indexPath.row]

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 280, height: 200))
        label.text = fontName
        label.font = UIFont(name: fontName, size: UIFont.systemFontSize)
        label.sizeToFit()

        return max(label.font.lineHeight + label.font.ascender + -label.font.descender, 44)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return familyNames[section]
    }

    /// This function is necessary because fonts shouldn't always be sorted alphabetically.
    /// For example, ArialMT should come before Arial-BoldItalicMT, but if we sort alphabetically, it doesn't.
    func sortFontNames(array: [String]) -> [String] {

        return array.sorted(by: { (s1: String, s2: String) -> Bool in
            // if s1 doesn't contain a hyphen, it should appear before s2
            let count1 = s1.components(separatedBy: "-").count
            if count1 == 1 {
                return true
            }

            // if s2 doesn't contain a hyphen, it should appear before s1
            let count2 = s2.components(separatedBy: "-").count
            if count2 == 1 {
                return false
            }

            // otherwise, a normal string compare will be fine
            return s1 > s2
        })
    }
}
