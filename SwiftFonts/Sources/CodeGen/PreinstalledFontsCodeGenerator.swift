import Foundation
import UIKit

/// Preinstalled  iOS font code generator
internal class PreinstalledFontsCodeGenerator: CodeGenerator {

    public static let shared = PreinstalledFontsCodeGenerator()
    
    /// Get a list of installed font family names
    public func listOfFamilyNames() -> [String] {
        return UIFont.familyNames
    }
    
    /// Get a list of installed font  names
    public func listOfFontNames() -> [String] {
        return listOfFamilyNames().flatMap{UIFont.fontNames(forFamilyName: $0)}
    }


    // MARK: - Private

    internal override func _generateCodeOutput(_ named: String? = nil) -> GeneratedCodeOutput {

        if let cached = _cached {
            return cached
        }

        let familyNames = UIFont.familyNames
        var sortedFamilyNames = familyNames.sorted()

        // remove family names with no fonts
        sortedFamilyNames = sortedFamilyNames.filter { !UIFont.fontNames(forFamilyName: $0).isEmpty }

        // check if were only generating code for a specific font
        if let trimmedName = named?.trimmed, !trimmedName.isEmpty {
            let lowercasedTrimmedName = trimmedName.lowercased()
            sortedFamilyNames = sortedFamilyNames.filter { $0.lowercased().contains(lowercasedTrimmedName) }
        }

        var allCode: String = "public extension Fonts {"
        var individualCodes: [String: String] = [:]

        sortedFamilyNames.forEach { familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            let sortedFontNames = fontNames.sorted()
            let fontNameEnum = sortedFontNames.map { "    case \(_normalized(faceName: $0)) = \"\($0)\"" }
            let fontNamesEnum = fontNameEnum.joined(separator: "\n")

            let individualFamily =  """

                    // MARK: - \(familyName)
                    enum \(_normalize(fontName: familyName)): String, FontRepresentable {
                    \(fontNamesEnum)
                    }

                    """

            allCode += individualFamily
            individualCodes[familyName] = individualFamily
        }

        allCode += "}"

        return setCache((allCode, individualCodes))
    }
    
    /// Override to handle problem fonts
    internal override func _normalized(faceName: String) -> String {

        let components = faceName.components(separatedBy: "-")

        if components.count > 1 {
            return _normalize(fontName: components[1]).lowercaseFirst
        } else {

            // Handle problem fonts
            let newFaceName = handleProblemFonts(faceName: faceName) ?? faceName

            // Let's see if we can determine the type based on capitalization
            let fontNameLowercaseStart = newFaceName.lowercaseFirst

            var displayString = ""
            var isCollecting = false

            for char in fontNameLowercaseStart {
                guard !isCollecting else {
                    displayString += String(char)
                    continue
                }

                if ("A"..."z").contains(char) {
                    displayString += String(char)
                    isCollecting = true
                }
            }

            return displayString.isEmpty || faceName.lowercased() == displayString.lowercased() ? "regular" : displayString.lowercaseFirst
        }
    }
    
    /// Some fonts give off unexpected behaviours, we must handle accordingly
    private func handleProblemFonts(faceName: String) -> String? {
        
        if faceName.contains("Damascus") {
            return faceName.replacingOccurrences(of: "Damascus", with: "")
        }
        
        return nil
    }
}
