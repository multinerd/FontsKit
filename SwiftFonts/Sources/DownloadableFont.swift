import Foundation
import UIKit

private let UndefinedFontSize = CGFloat(1)

public let FontDidBecomeAvailableNotification = Notification.Name("io.multinerd.downloadableFontsCodeGenerator.fontDidBecomeAvailable")
public let FontNameInfoKey = "FontNameInfoKey"

public typealias DownloadProgressHandler = (_ downloadedSize: Int, _ totalSize: Int, _ percentage: Int) -> Void
public typealias DownloadCompletionHandler = (_ font: UIFont?) -> Void

public protocol DownloadableFont: FontRepresentable {
}

extension UIFont {

    public static func downloadableFontNames(excludeInstalled: Bool = true) -> [String] {

        let dict = [kCTFontDownloadableAttribute: kCFBooleanTrue] as CFDictionary

        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes(dict)
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil) else {
            return []
        }

        guard let matchedDescriptors = cfMatchedDescriptors as? [CTFontDescriptor] else {
            return []
        }

        var downloadableFonts = matchedDescriptors.compactMap { (descriptor) -> String? in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            return attributes[kCTFontNameAttribute as String] as? String
        }

        if excludeInstalled {
            downloadableFonts = Array(Set(downloadableFonts).subtracting(UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }))
        }

        return downloadableFonts
    }

    public class func fontExists(name: String) -> Bool {

        return UIFont(name: name, size: UndefinedFontSize) != nil
    }

    public class func preload(name: String) {

        if fontExists(name: name) {
            return
        }
        downloadFontWithName(name: name, size: UndefinedFontSize)
    }

    public class func downloadFontWithName(name: String, size: CGFloat, progress: DownloadProgressHandler? = nil, completion: DownloadCompletionHandler? = nil) {

        let wrappedCompletionHandler = { (postNotification: Bool) -> Void in
            DispatchQueue.main.async {
                let font = UIFont(name: name, size: size)
                if postNotification && font != nil {
                    NotificationCenter.default.post(name: FontDidBecomeAvailableNotification, object: nil, userInfo: [FontNameInfoKey: name])
                }
                completion?(font)
            }
        }
        if fontExists(name: name) {
            wrappedCompletionHandler(false)
            return
        }
        let wrappedProgressHandler = { (param: NSDictionary) -> Void in
            DispatchQueue.main.async {
                let downloadedSize = param[kCTFontDescriptorMatchingTotalDownloadedSize as String] as? Int ?? 0
                let totalSize = param[kCTFontDescriptorMatchingTotalAssetSize as String] as? Int ?? 0
                let percentage = param[kCTFontDescriptorMatchingPercentage as String] as? Int ?? 0
                progress?(downloadedSize, totalSize, percentage)
            }
        }
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler([CTFontDescriptorCreateWithNameAndSize(name as CFString, size)] as CFArray, nil) { (state, param) -> Bool in
            switch state {
                case .willBeginDownloading, .stalled, .downloading, .didFinishDownloading:
                    wrappedProgressHandler(param)
                case .didFinish:
                    wrappedCompletionHandler(true)
                default:
                    break
            }
            return true
        }
    }
}
