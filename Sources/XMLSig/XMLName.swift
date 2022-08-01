public struct XMLName:
    Equatable,
    Hashable,
    Comparable,
    CustomStringConvertible
{
    public var namespace: XMLNamespaceName
    public var name: String

    public init(
        namespace: XMLNamespaceName,
        name: String
    ) {
        self.namespace = namespace
        self.name = name
    }

    public init(from string: String) {
        var string = string
        var namespace: XMLNamespaceName = .default

        if let index = string.firstIndex(of: ":") {
            namespace = XMLNamespaceName(String(string[..<index]))

            let nextIndex = string.index(after: index)
            string = String(string[nextIndex...])
        }

        self.init(
            namespace: namespace,
            name: string
        )
    }

    public var description: String {
        var s = ""
        if namespace != .default {
            s += "\(namespace):"
        }
        s += name
        return s
    }

    public static func <(a: XMLName, b: XMLName) -> Bool {
        if a.namespace != b.namespace {
            return a.namespace < b.namespace
        }
        return a.name < b.name
    }

    public func withURI(namespaces: [XMLNamespaceName: String]) throws -> XMLNameWithURI {
        guard let uri = namespaces[namespace] else {
            throw MessageError("unknown namespace: \(namespace)")
        }
        return withURI(uri: uri)
    }

    public func withURI(uri: String) -> XMLNameWithURI {
        return XMLNameWithURI(
            uri: uri,
            name: self
        )
    }
}

public struct XMLNameWithURI {
    public var name: XMLName
    public var uri: String
    public init(
        uri: String,
        name: XMLName
    ) {
        self.name = name
        self.uri = uri
    }
}
