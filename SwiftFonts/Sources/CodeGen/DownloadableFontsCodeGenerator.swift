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

        
        let cfDict = [
            kCTFontDownloadableAttribute: kCFBooleanTrue
            ] as CFDictionary
        
        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes(cfDict)
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil),
            let matchedDescriptors = cfMatchedDescriptors as? [CTFontDescriptor] else {
            fatalError()
        }
        
        var results: [String: [String]] = [:]
        matchedDescriptors.forEach { (descriptor) in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            
            guard let familyName = attributes[kCTFontFamilyNameAttribute as String] as? String,
                let fontName = attributes[kCTFontNameAttribute as String] as? String else {
                    return
            }
            
            if results[familyName] == nil {
                results[familyName] = []
            }
            
            results[familyName]?.append(fontName)
            
        }
        
        _cachedList = Cached(results)
        return results
        
        
        
//        // Fonts.json is taken from https://iosfontlist.com/fonts.json
//        // Included in app in the event the site is no longer accessible.
//        // TODO Find a native way to group font names by font family.
//        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Fonts", ofType: ".json")!)
//        let iOSFonts = try? IOSFonts(fromURL: url)
//        let downloadable = iOSFonts?.filter { !$0.fonts.filter { $0.downloadable != "0.0" && $0.preinstalled == "0.0" }.isEmpty }
//
//        // Exclude fonts in UIFont.familyNames
//        // downloadable = iOSFonts?.filter { !UIFont.familyNames.contains($0.main) }
//
//        var dict: [String: [String]] = [:]
//        downloadable?.sorted { $0.title < $1.title }.forEach({ (family) in
//            dict[family.title] = family.fonts.compactMap { $0.font }
//        })
//
//        // TODO handle fonts in native method not listed in json feed
//
//        _cachedList = Cached(dict)
//        return dict
    }

    // MARK: - Code Gen

    internal override func _generateCodeOutput(_ named: String? = nil) -> GeneratedCodeOutput {

        if let cached = _cached?.cached {
            return cached
        }

        let lookupDict = listOfFontsByFamily()
        let familyNames = Array(Set(lookupDict.keys))//.subtracting(UIFont.familyNames))
        
        var sortedFamilyNames = familyNames.sorted()

        // remove family names with no fonts
        sortedFamilyNames = sortedFamilyNames.filter { !(lookupDict[$0]?.isEmpty ?? false) }

        // check if were only generating code for a specific font
        if let trimmedName = named?.trimmed, !trimmedName.isEmpty {
            let lowercasedTrimmedName = trimmedName.lowercased()
            sortedFamilyNames = sortedFamilyNames.filter { $0.lowercased().contains(lowercasedTrimmedName) }
        }

        var allCode: String = "public extension Fonts {"
        var individualCodes: [String: String] = [:]

        sortedFamilyNames.forEach { familyName in
            guard let fontNames = lookupDict[familyName] else { return }

            var fontNamesEnum = ""
            if fontNames.count == 1 {
                fontNamesEnum = "    case regular = \"\(fontNames[0])\""
            } else {
                let sortedFontNames = fontNames.sorted()
                let fontNameEnum = sortedFontNames.map { "    case \(_normalize(faceName: $0)) = \"\($0)\"" }
                fontNamesEnum = fontNameEnum.joined(separator: "\n")
            }

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
