public struct XMLNamespaceAttribute: Equatable, CustomStringConvertible {
    public var namespace: XMLNamespaceName
    public var uri: String

    public init(
        namespace: XMLNamespaceName,
        uri: String
    ) {
        self.namespace = namespace
        self.uri = uri
    }

    public var description: String {
        let name: XMLName = {
            if namespace == .default {
                // 見かけの辻褄を合わせる
                return XMLName(namespace: .default, name: "xmlns")
            } else {
                return XMLName(namespace: .xmlns, name: namespace.rawValue)
            }
        }()

        let attribute = XMLAttribute(
            name: name,
            value: uri
        )
        return attribute.description
    }
}
