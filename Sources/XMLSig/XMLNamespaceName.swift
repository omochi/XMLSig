public struct XMLNamespaceName:
    RawRepresentable,
    Equatable,
    Hashable,
    Comparable,
    CustomStringConvertible
{
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }

    public var description: String {
        rawValue.description
    }

    public var isDefault: Bool {
        self == .default
    }

    public static let `default` = XMLNamespaceName(rawValue: "")
    public static let xmlns = XMLNamespaceName(rawValue: "xmlns")

    public static func <(a: XMLNamespaceName, b: XMLNamespaceName) -> Bool {
        a.rawValue < b.rawValue
    }
}
