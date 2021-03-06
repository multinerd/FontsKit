import Foundation

public class Cached<T> {

    private var _cached: T

    // Set cache
    public init(_ cache: T) {

        _cached = cache
    }

    // Get cached
    public var cached: T {
        return _cached
    }
}
