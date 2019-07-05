//
//  UIFont+DownloadableFont.swift
//  SwiftFonts
//
//  Created by Michael Hedaitulla on 7/5/19.
//

import Foundation
import UIKit


extension UIFont {

    /// Create a UIFont object with a `Font` enum
    public convenience init?<T: DownloadableFont>(font: T, size: CGFloat) {
        font.preloadFont()
        self.init(name: font.rawValue, size: size)
    }
}



extension UIFont {
    
    public static func downloadableFontNames(excludeInstalled: Bool = true) -> [String] {
        
        let dict = [
            kCTFontDownloadableAttribute: kCFBooleanTrue
            ] as CFDictionary
        
        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes(dict)
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil) else {
            return []
        }
        
        guard let matchedDescriptors = cfMatchedDescriptors as? [CTFontDescriptor] else {
            return []
        }
        
        var downloadableFonts =  matchedDescriptors.compactMap { (descriptor) -> String? in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            return attributes[kCTFontNameAttribute as String] as? String
        }
        
        if excludeInstalled {
            downloadableFonts = Array(Set(downloadableFonts).subtracting(UIFont.familyNames.flatMap{UIFont.fontNames(forFamilyName: $0)}))
        }
        
        return downloadableFonts
    }
}
