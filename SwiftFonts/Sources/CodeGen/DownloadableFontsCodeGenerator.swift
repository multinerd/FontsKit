import Foundation
import UIKit

/// Downloadable  iOS font code generator
internal class DownloadableFontsCodeGenerator: CodeGenerator {

    public static let shared = DownloadableFontsCodeGenerator()

    // MARK: - Font Names

    public override func listOfFontsByFamily() -> [String: [String]] {

        if let cached = _cachedList?.cached {
            return cached
        }

        let cfDict = [kCTFontDownloadableAttribute: kCFBooleanTrue] as CFDictionary

        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes(cfDict)
        guard let matchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil) as? [CTFontDescriptor] else {
            fatalError()
        }

        var results: [String: [String]] = [:]
        matchedDescriptors.forEach { (descriptor) in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary

            guard let familyName = attributes[kCTFontFamilyNameAttribute as String] as? String else {
                return
            }

            if results[familyName] == nil {
                results[familyName] = []
            }

            guard let fontName = attributes[kCTFontNameAttribute as String] as? String else {
                return
            }

            results[familyName]?.append(fontName)
        }

        _cachedList = Cached(results)
        return results
    }

    // MARK: - Code Gen

    internal override func _generateCodeOutput(_ named: String? = nil) -> GeneratedCodeOutput {

        if let cached = _cached?.cached {
            return cached
        }

        let lookupDict = listOfFontsByFamily()

        let familyNames = lookupDict.keys // Array(Set(lookupDict.keys).subtracting(UIFont.familyNames)) // Uncomment to exclude preinstalled fonts
        var sortedFamilyNames = familyNames.sorted()

        // remove family names with no fonts
        sortedFamilyNames = sortedFamilyNames.filter { !(lookupDict[$0]?.isEmpty ?? false) }

        // check if were only generating code for a specific font
        if let trimmedName = named?.trimmed, !trimmedName.isEmpty {
            let lowercasedTrimmedName = trimmedName.lowercased()
            sortedFamilyNames = sortedFamilyNames.filter { $0.lowercased().contains(lowercasedTrimmedName) }
        }

        var allCode: String = "public extension Fonts.Downloadable {"
        var individualCodes: [String: String] = [:]

        sortedFamilyNames.forEach { familyName in
            guard let fontNames = lookupDict[familyName] else { return }

            let sortedFontNames = fontNames.sorted()
            let fontNameEnum = sortedFontNames.map { "    case \(_normalize(faceName: $0)) = \"\($0)\"" }
            let fontNamesEnum = fontNameEnum.joined(separator: "\n")

            let individualFamily = """

                                   // MARK: - \(familyName)
                                   enum \(_normalize(fontName: familyName)): String, DownloadableFont {
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
