public struct XMLNodePathItem: RawRepresentable {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public typealias XMLNodePath = [XMLNodePathItem]
