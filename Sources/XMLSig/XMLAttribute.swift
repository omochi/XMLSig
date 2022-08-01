public struct XMLAttribute: Equatable, CustomStringConvertible {
    public var name: XMLName
    public var value: String

    public init(
        name: XMLName,
        value: String
    ) {
        self.name = name
        self.value = value
    }

    public var description: String {
        let q = "\""
        var s = ""
        s += name.description
        s += "="
        s += q
        s += XMLCanonicalization.esacpeAttributeValue(value)
        s += q
        return s
    }

    public func withURI(namespaces: [XMLNamespaceName: String]) throws -> XMLAttributeWithURI {
        guard let uri = namespaces[name.namespace] else {
            throw MessageError("unknown namespace: \(name.namespace)")
        }
        return withURI(uri: uri)
    }

    public func withURI(uri: String) -> XMLAttributeWithURI {
        return XMLAttributeWithURI(
            name: XMLNameWithURI(uri: uri, name: name),
            value: value
        )
    }
}

public struct XMLAttributeWithURI {
    public var name: XMLNameWithURI
    public var value: String

    public init(
        name: XMLNameWithURI,
        value: String
    ) {
        self.name = name
        self.value = value
    }

    public var attribute: XMLAttribute {
        XMLAttribute(
            name: name.name,
            value: value
        )
    }
}
