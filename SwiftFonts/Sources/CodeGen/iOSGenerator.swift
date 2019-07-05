//
//  iOSGenerator.swift
//  SwiftFonts
//
//  Created by Michael Hedaitulla on 7/4/19.
//  Copyright © 2019 Roadfire Software. All rights reserved.
//

import Foundation
import UIKit

public struct iOSGenerator {
    
    
    /// Outputs code to debugger output.
    public static func generateCodeToDebugger() {
        _generateiOSFontsCode().individual.sorted { $0.key < $1.key }.forEach {
            print($0.value + "\n")
        }
    }
    
    
    public static func generateCode(directoryPath: String) {
        _generateiOSFontsCode().individual.forEach {
            do {
                try $0.value.write(toFile: (directoryPath+$0.key), atomically: false, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
    }
    
    public static func generateCode(filePath: String) {
        do {
            try _generateiOSFontsCode().full.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    
    
    private typealias GeneratedCodeAlias = (full: String, individual: [String:String])
    private static func _generateiOSFontsCode(named: String = "") -> GeneratedCodeAlias {
        
        let familyNames = UIFont.familyNames
        var sortedFamilyNames = familyNames.sorted()
        
        // remove family names with no fonts
        sortedFamilyNames = sortedFamilyNames
            .filter { !UIFont.fontNames(forFamilyName: $0).isEmpty }
        
        // check if were only generating code for a specific font
        let trimmedName = named.trimmed
        if !trimmedName.isEmpty {
            let lowercasedTrimmedName = trimmedName.lowercased()
            sortedFamilyNames = sortedFamilyNames
                .filter { $0.lowercased().contains(lowercasedTrimmedName) }
        }
        
        var allCode: String = String()
        var individualCodes: [String: String] = [:]
        
        sortedFamilyNames.forEach { familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            let sortedFontNames = fontNames.sorted()
            let fontNameEnum = sortedFontNames.map { "    case \(_normalized(faceName: $0)) = \"\($0)\"" }
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
        
        return (allCode, individualCodes)
    }
    
    
    
    static func _normalize(fontName: String) -> String {
        return fontName
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercaseFirst
    }
    
    static func _normalized(faceName: String) -> String {
        
        let components = faceName.components(separatedBy: "-")
        
        if components.count > 1 {
            return _normalize(fontName: components[1])
        }
        else {
            // Let's see if we can determine the type based on capitalization
            let fontNameLowercaseStart = faceName.lowercaseFirst
            
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
            
//            let fontsWithNoNoDashes = ["damascus"]
//            if fontsWithNoNoDashes.contains(displayString) {
//                fontName = fontName.remove(prefix: "Damascus")
//                displayString = displayString.remove(prefix: "damascus")
//            }
            
            return displayString.isEmpty || faceName.lowercased() == displayString.lowercased()
                ? "regular"
                : displayString.lowercaseFirst
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



