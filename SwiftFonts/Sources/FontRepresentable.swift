import Foundation
import UIKit

/// A type that represents a font and can generate a `UIFont` object.
public protocol FontRepresentable: RawRepresentable where Self.RawValue == String {
    func of(size: CGFloat) -> UIFont

    @available(iOS 11.0, *)
    func of(textStyle: UIFont.TextStyle, defaultSize: CGFloat?, maxSize: CGFloat?) -> UIFont

    @available(iOS, introduced: 8.2, deprecated: 11.0, message: "Use `of(textStyle:maxSize:defaultSize:)` instead") 
    func of(style: UIFont.TextStyle, maxSize: CGFloat?) -> UIFont
}

public extension FontRepresentable {

    /// Creates a font object of the specified size.
    ///
    /// # ⚠️ Important Notes: #
    /// 1. If the font fails to initialize in a debug build (using `-Onone` optimization), a fatal error will be thrown.
    ///   This is done to help catch boilerplate typos in development.
    /// 2. Instead of using this method to get a font, it’s often more appropriate to use `of(textStyle:defaultSize:maxSize:)`
    ///   because that method respects the user’s selected content size category.
    ///
    /// - Parameter size: The text size for the font.
    func of(size: CGFloat) -> UIFont {

        guard let font = UIFont(name: rawValue, size: size) else {
            // If font not found, crash debug builds.
            assertionFailure("Font not found: \(rawValue)")
            return .systemFont(ofSize: size)
        }

        return font
    }

    /// Creates a dynamic font object corresponding to the given parameters.
    ///
    /// # ⚠️ Important Notes: #
    /// 1. If the font fails to initialize in a debug build (using `-Onone` optimization), a fatal error will be thrown.
    ///   This is done to help catch boilerplate typos in development.
    /// 2. If no default size is provided, the default specified in Apple's Human Interface Guidelines
    ///   ([iOS](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/)) is used.
    ///
    /// - Parameter textStyle: The text style used to scale the text.
    /// - Parameter defaultSize: The base size used for text scaling. Corresponds to `UIContentSizeCategory.large`.
    /// - Parameter maxSize: The size which the text may not exceed.
    @available(iOS 11.0, *)
    func of(textStyle: UIFont.TextStyle, defaultSize: CGFloat? = nil, maxSize: CGFloat? = nil) -> UIFont {

        // If no default size provided, use the default specified in Apple's HIG
        guard let defaultSize = defaultSize ?? defaultSizes[textStyle] else {
            assertionFailure("""
                             Text style \(textStyle.rawValue) is not accounted for in Swash's
                             default size dictionary 🤭. Either Apple's HIG has not specified a
                             default size for \(textStyle.rawValue) for the device you are using,
                             or it was recently added and this library needs to be updated (GitHub
                             issues and pull requests are much appreciated!). In any case, at
                             least for now, you must provide a default size to use this text style.
                             """)
            return of(size: 17)
        }

        let font = of(size: defaultSize)
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)

        if let maxSize = maxSize {
            return fontMetrics.scaledFont(for: font, maximumPointSize: maxSize)
        } else {
            return fontMetrics.scaledFont(for: font)
        }
    }

    /// Creates a font object sized based on the given parameters.
    ///
    /// # ⚠️ Important Notes: #
    /// 1. If the font fails to initialize in a debug build (using `-Onone` optimization), a fatal error will be thrown.
    ///   This is done to help catch boilerplate typos in development.
    ///
    /// - Parameter style: The text style used to scale the text.
    /// - Parameter maxSize: Size which the text may not exceed.
    @available(iOS, introduced: 8.2, deprecated: 11.0, message: "Use `of(textStyle:maxSize:defaultSize:)` instead") 
    func of(style: UIFont.TextStyle, maxSize: CGFloat? = nil) -> UIFont {

        let pointSize = UIFont.preferredFont(forTextStyle: style).pointSize

        if let maxSize = maxSize, pointSize > maxSize {
            return of(size: maxSize)
        } else {
            return of(size: pointSize)
        }
    }
}



/*
 public func of(size: CGFloat, scaling: Bool) -> UIFont? {
     let newSize = scaling ? GBRatio * size : size
     // print("Font Size : " , (UIScreen.main.bounds.size.width * size)/414)
     // return UIFont(name: rawValue, size: (UIScreen.main.bounds.size.width * size)/414)
     // return UIFont(name: rawValue, size: GBRatio * size)
     return UIFont(name: rawValue, size: newSize)
 }
 */
