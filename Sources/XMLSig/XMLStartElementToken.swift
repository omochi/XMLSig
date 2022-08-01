import Collections

public struct XMLStartElementToken: Equatable, CustomStringConvertible {
    public var name: XMLName
    public var namespaces: OrderedDictionary<XMLNamespaceName, String>
    public var attributes: OrderedDictionary<XMLName, String>

    public init(
        name: XMLName,
        namespaces: OrderedDictionary<XMLNamespaceName, String> = [:],
        attributes: OrderedDictionary<XMLName, String> = [:]
    ) {
        self.name = name
        self.namespaces = namespaces
        self.attributes = attributes
    }

    public var description: String {
        var s = "<"
        s += name.description
        for (namespace, uri) in namespaces {
            let attribute = XMLNamespaceAttribute(namespace: namespace, uri: uri)
            s += " "
            s += attribute.description
        }
        for (name, value) in attributes {
            let attribute = XMLAttribute(name: name, value: value)
            s += " "
            s += attribute.description
        }
        s += ">"
        return s
    }
}
