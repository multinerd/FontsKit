import Foundation
import UIKit

public let FontDidBecomeAvailableNotification = Notification.Name("io.multinerd.downloadableFontsCodeGenerator.fontDidBecomeAvailable")
public let FontNameInfoKey = "FontNameInfoKey"

public typealias DownloadProgressHandler = (_ downloadedSize: Int, _ totalSize: Int, _ percentage: Int) -> Void
public typealias DownloadCompletionHandler = (_ font: UIFont?) -> Void


/// Downloadable  iOS font code generator
internal class DownloadableFontsCodeGenerator: CodeGenerator {
    
    public static let shared = DownloadableFontsCodeGenerator()
    
    internal var _cachedList: Cached<[String:[String]]>? = nil
    
    public func listOfFontsByFamily() -> [String : [String]] {
        
        if let cached = _cachedList?.cached {
            return cached
        }
        
        let iOSFonts = try? IOSFonts(fromURL: URL(string: "https://iosfontlist.com/fonts.json")!)
        let downloadable = iOSFonts?.filter { !$0.fonts.filter { $0.downloadable != "0.0" && $0.preinstalled == "0.0" }.isEmpty }
        
        var dict: [String: [String]] = [:]
        downloadable?.sorted{$0.title < $1.title}.forEach({ (family) in
            dict[family.main] = family.fonts.compactMap { $0.font }
        })
        
        _cachedList =  Cached(dict)
        return _cachedList!.cached
    }
    
    public func listOfFontNames(excludeInstalled: Bool = true) -> [String] {
        return UIFont.downloadableFontNames(excludeInstalled: excludeInstalled)
    }
    
    



    
    
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
        
        var allCode: String = "public extension Fonts {"
        var individualCodes: [String: String] = [:]
        
        sortedFamilyNames.forEach { familyName in
            guard let fontNames = lookupDict[familyName] else { return }
            
            var fontNamesEnum = ""
            if fontNames.count == 1 {
                fontNamesEnum =  "    case regular = \"\(fontNames[0])\""
            } else {
                let sortedFontNames = fontNames.sorted()
                let fontNameEnum = sortedFontNames.map { "    case \(_normalized(faceName: $0)) = \"\($0)\"" }
                fontNamesEnum = fontNameEnum.joined(separator: "\n")
            }

            
            let individualFamily =  """
            
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





// MARK: - IOSFont
public struct IOSFont: Codable, Hashable {
    public let title: String
    public let main: String
    public let fonts: [Font]
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case main = "main"
        case fonts = "fonts"
    }
    
    public init(title: String, main: String, fonts: [Font]) {
        self.title = title
        self.main = main
        self.fonts = fonts
    }
}

// MARK: IOSFont convenience initializers and mutators

public extension IOSFont {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IOSFont.self, from: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Font
public struct Font: Codable, Hashable {
    public let title: String
    public let font: String
    public let preinstalled: String
    public let downloadable: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case font = "font"
        case preinstalled = "preinstalled"
        case downloadable = "downloadable"
    }
    
    public init(title: String, font: String, preinstalled: String, downloadable: String) {
        self.title = title
        self.font = font
        self.preinstalled = preinstalled
        self.downloadable = downloadable
    }
}

// MARK: Font convenience initializers and mutators

public extension Font {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Font.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        title: String? = nil,
        font: String? = nil,
        preinstalled: String? = nil,
        downloadable: String? = nil
        ) -> Font {
        return Font(
            title: title ?? self.title,
            font: font ?? self.font,
            preinstalled: preinstalled ?? self.preinstalled,
            downloadable: downloadable ?? self.downloadable
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public typealias IOSFonts = [IOSFont]

public extension Array where Element == IOSFonts.Element {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IOSFonts.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
