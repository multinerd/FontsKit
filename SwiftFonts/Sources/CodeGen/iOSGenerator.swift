import Foundation
import UIKit

/// Native iOS font code generator
public class iOSGenerator {

    public static let shared = iOSGenerator()

    /// Outputs code to debugger output.
    public func generateCodeToDebugger() {

        _generateiOSFontsCode().individual.sorted { $0.key < $1.key }.forEach {
            print($0.value + "\n")
        }
    }

    /// Output individual files to a specidied directory path.
    /// - Parameter named: An optional font name to generate. Can be ommited to generate all fonts.
    /// - Parameter directoryPath: The output directory path.
    public func generateCode(named: String? = nil, directoryPath: String) {

        _generateiOSFontsCode(named).individual.forEach {
            do {
                let folderPath = "\(directoryPath)\($0.key)"
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: [:])

                let filePath = "\(folderPath)/\($0.key).swift"
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: [:])

                try $0.value.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
        print("Code output to \(directoryPath)")
    }

    /// Output a single file containing all the fonts.
    /// - Parameter named: An optional font name to generate. Can be ommited to generate all fonts.
    /// - Parameter filePath: The output file path.
    public func generateCode(named: String? = nil, filePath: String) {

        do {
            try _generateiOSFontsCode(named).full.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error.userInfo)
        }
        print("Code output to \(filePath)")
    }

    // MARK: - Caching

    private var _cached: GeneratedCodeAlias? = nil

    private func setCache(cache: GeneratedCodeAlias) -> GeneratedCodeAlias {

        _cached = cache
        return _cached!
    }

    public func clearCache() {

        _cached = nil
    }

    // MARK: - Private

    private typealias GeneratedCodeAlias = (full: String, individual: [String: String])

    private func _generateiOSFontsCode(_ named: String? = nil) -> GeneratedCodeAlias {

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

        return setCache(cache: (allCode, individualCodes))
    }

    private func _normalize(fontName: String) -> String {

        return fontName.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "_", with: "").replacingOccurrences(of: " ", with: "")
        //            .lowercaseFirst
    }

    /// Some fonts give off unexpected behaviours, we must handle accordingly
    func handleProblemFonts(faceName: String) -> String? {

        if faceName.contains("Damascus") {
            return faceName.replacingOccurrences(of: "Damascus", with: "")
        }

        return nil
    }

    private func _normalized(faceName: String) -> String {

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
}

extension String {

    var first: String {
        return String(prefix(1))
    }

    var last: String {
        return String(suffix(1))
    }

    var uppercaseFirst: String {
        return first.uppercased() + String(dropFirst())
    }

    var lowercaseFirst: String {
        return first.lowercased() + String(dropFirst())
    }

    var trimmed: String {
        return self.trimmingCharacters(in: .whitespaces)
    }

    func remove(prefix: String) -> String {

        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}




