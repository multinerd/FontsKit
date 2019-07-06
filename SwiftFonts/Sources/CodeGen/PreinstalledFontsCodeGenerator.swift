import Foundation
import UIKit

/// Preinstalled  iOS font code generator
internal class PreinstalledFontsCodeGenerator: CodeGenerator {

    public static let shared = PreinstalledFontsCodeGenerator()

    // MARK: - Font Names

    public override func listOfFontsByFamily() -> [String: [String]] {

        if let cached = _cachedList?.cached {
            return cached
        }

        var dict: [String: [String]] = [:]
        UIFont.familyNames.sorted().forEach({ (family) in
            dict[family] = UIFont.fontNames(forFamilyName: family)
        })

        _cachedList = Cached(dict)
        return dict
    }

    // MARK: - Code Gen

    internal override func _generateCodeOutput(_ named: String? = nil) -> GeneratedCodeOutput {

        if let cached = _cached?.cached {
            return cached
        }

        let lookupDict = listOfFontsByFamily()

        let familyNames = lookupDict.keys
        var sortedFamilyNames = familyNames.sorted()

        // remove family names with no fonts
        sortedFamilyNames = sortedFamilyNames.filter { !(lookupDict[$0]?.isEmpty ?? false) }

        // check if were only generating code for a specific font
        if let trimmedName = named?.trimmed, !trimmedName.isEmpty {
            let lowercasedTrimmedName = trimmedName.lowercased()
            sortedFamilyNames = sortedFamilyNames.filter { $0.lowercased().contains(lowercasedTrimmedName) }
        }

        var allCode: String = "public extension Fonts.Native {"
        var individualCodes: [String: String] = [:]

        sortedFamilyNames.forEach { familyName in
            guard let fontNames = lookupDict[familyName] else { return }

            let sortedFontNames = fontNames.sorted()
            let fontNameEnum = sortedFontNames.map { "    case \(_normalize(faceName: $0)) = \"\($0)\"" }
            let fontNamesEnum = fontNameEnum.joined(separator: "\n")

            let individualFamily = """

                                   // MARK: - \(familyName)
                                   enum \(_normalize(fontName: familyName)): String, FontRepresentable {
                                   \(fontNamesEnum)
                                   }

                                   """

            allCode += individualFamily
            individualCodes[familyName] = individualFamily
        }

        allCode += "}"

        _cached = Cached((allCode, individualCodes))
        return _cached!.cached
    }
}
