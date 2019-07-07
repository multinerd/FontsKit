import Foundation
import UIKit

internal let apiKey: String? = "AIzaSyDQMIdsv2dwnyhRSmJgyoOugNC1-KUEa5w"

/// Preinstalled  iOS font code generator
internal class GoogleFontsCodeGenerator: CodeGenerator {

    public static let shared = GoogleFontsCodeGenerator()

    // MARK: - Font Names

    public override func listOfFontsByFamily() -> [String: [String]] {

        if let cached = _cachedList?.cached {
            return cached
        }

        let googleFonts = getFontsFromApi()
        var results: [String: [String]] = [:]

        googleFonts.items.forEach { item in

            if results[item.family] == nil {
                results[item.family] = []
            }

            item.files.forEach { file in
                let fontName = "\(_normalize(fontName: item.family))-\(_normalize(variantName: file.key))"
                results[item.family]?.append(fontName)
            }
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

        var allCode: String = "public extension Fonts.Google {"
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
    
    internal func downloadFonts(_ rootDirectory: String) {
        
        create(directory: rootDirectory)
        
        getFontsFromApi().items.forEach { item in
            
            item.files.forEach { file in
                let fontName = "\(_normalize(fontName: item.family))-\(_normalize(variantName: file.key))"
             
                let familyDir = rootDirectory.append(path: item.family)
                create(directory: familyDir)
                
                let versionDir = familyDir.append(path: item.version + " Resources")
                create(directory: versionDir)
                
                print("Downloading \(item.family): \(fontName)")
                
                guard let url = URL(string: file.value), let fontData = try? Data(contentsOf: url) else {
                    print("Failed to download font: \(item.family)\(fontName)")
                    return
                }
                
                let filename = versionDir.append(path: fontName + ".ttf")
                create(file: filename, data: fontData)
            }
        }
    }
    
    
    func create(file: String, data: Data) {
        FileManager.default.createFile(atPath: file, contents: data, attributes: [:])
    }
    
    func create(directory: String) {
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: [:])
    }
    
    
    internal func getFontsFromApi() -> GoogleFonts {

        guard let apiKey = apiKey else {
            fatalError("API key not set")
        }

        guard let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(apiKey)"), let jsonData = try? Data(contentsOf: url), let googleFonts = try? JSONDecoder().decode(GoogleFonts.self, from: jsonData) else {
            fatalError("Failed to parse json response")
        }

        return googleFonts
    }
}



extension GoogleFontsCodeGenerator {
    
    func allInOne() {
        
    }
}
