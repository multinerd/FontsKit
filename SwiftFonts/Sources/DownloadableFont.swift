import Foundation
import UIKit

private let UndefinedFontSize = CGFloat(1)

public let FontDidBecomeAvailableNotification = Notification.Name("io.multinerd.downloadableFontsCodeGenerator.fontDidBecomeAvailable")
public let FontNameInfoKey = "FontNameInfoKey"

public typealias DownloadProgressHandler = (_ downloadedSize: Int, _ totalSize: Int, _ percentage: Int) -> Void
public typealias DownloadCompletionHandler = (_ font: UIFont?) -> Void

public protocol DownloadableFont: FontRepresentable {
}

extension DownloadableFont {

    public func fontExists() -> Bool {

        return UIFont(name: self.rawValue, size: UndefinedFontSize) != nil
    }

    public func preloadFont() {

        if fontExists() {
            return
        }
        downloadFontWithName(name: self.rawValue, size: UndefinedFontSize)
    }

    public func downloadFontWithName(name: String, size: CGFloat, progress: DownloadProgressHandler? = nil, completion: DownloadCompletionHandler? = nil) {

        let wrappedCompletionHandler = { (postNotification: Bool) -> Void in
            DispatchQueue.main.async {
                let font = UIFont(name: name, size: size)
                if postNotification && font != nil {
                    NotificationCenter.default.post(name: FontDidBecomeAvailableNotification, object: nil, userInfo: [FontNameInfoKey: name])
                }
                completion?(font)
            }
        }
        if fontExists() {
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
