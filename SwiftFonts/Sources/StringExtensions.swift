import Foundation

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
    
    func append(path: String) -> String {
        if !self.hasSuffix("/") {
            return self + "/" + path
        }
        return self + path
    }
}
