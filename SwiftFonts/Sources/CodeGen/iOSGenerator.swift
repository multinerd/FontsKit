//
//  iOSGenerator.swift
//  SwiftFonts
//
//  Created by Michael Hedaitulla on 7/4/19.
//  Copyright © 2019 Roadfire Software. All rights reserved.
//

import Foundation

//
//  Utils.swift
//  Swash
//
//  Created by Sam Francis on 1/29/18.
//

import UIKit


/**
 Logs an attempt at generating custom font boilerplate.
 
 - Parameter filter: Used to narrow the log to your desired fonts. Case is ignored. Defaults to empty string.
 */
public func logBoilerplate(forFontsWithFamilyNamesContaining filter: String = "") {
    let trimmedFilter = filter.trimmingCharacters(in: .whitespaces).lowercased()
    UIFont.familyNames.sorted()
        .filter { !UIFont.fontNames(forFamilyName: $0).isEmpty }
        .filter { !trimmedFilter.isEmpty && $0.lowercased().contains(trimmedFilter) || trimmedFilter == "" }
        .forEach { familyName in
            var str = "\n// MARK: - \(familyName)"
            str += "\nenum \(normalizeFontName(familyName)): String, FontRepresentable {\n"
            str += UIFont.fontNames(forFamilyName: familyName)
                .sorted()
                .map { "\tcase \(normalizedFaceName($0)) = \"\($0)\"" }
                .joined(separator: "\n")
            
            str += "\n}"
            print(str)
    }
}


func normalizeFontName(_ fontName: String) -> String {
    
    return fontName
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: "_", with: "")
        .replacingOccurrences(of: " ", with: "")
        .lowercaseFirst
}

func normalizedFaceName(_ fontName: String) -> String {
    
    let components = fontName.components(separatedBy: "-")
    
    if components.count > 1
    {
        return normalizeFontName(components[1])
    }
    else
    {
        // Let's see if we can determine the type based on capitalization
        let fontNameLowercaseStart = fontName.lowercaseFirst
        
        var displayString = ""
        var isCollecting = false
        
        for char in fontName
        {
            guard !isCollecting else {
                displayString += String(char)
                continue
            }
            
            if ("A"..."z").contains(char)
            {
                displayString += String(char)
                isCollecting = true
            }
        }
        
        return displayString.isEmpty || fontName.lowercased() == displayString.lowercased()
            ? "regular"
            : displayString.lowercaseFirst
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
}
