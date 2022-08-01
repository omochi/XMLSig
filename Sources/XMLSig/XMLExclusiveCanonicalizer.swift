import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Collections

/*
 SAMLで必要なExclusive XML Canonicalizationを実装する。
 規格書: https://www.w3.org/TR/xml-exc-c14n/

 SAMLで必要にならない仕様は適当に無視する。
 特に Foundation.XMLDocument の仕様のため実現困難な部分もある。
 */

public struct XMLExclusiveCanonicalizer {
    public init() {
    }

    public func canonicalize(document: XMLElementNode) throws {
        var c = Canonicalize()
        try c(document: document)
    }

    public func canonicalize(xml: Data) throws -> String {
        let parser = XMLParser()
        let document = try parser.parse(xml: xml)
        try canonicalize(document: document)
        return document.description
    }
}

private struct Canonicalize {
    /*
     再帰アルゴリズムにおけるスタックごとの状態
     */
    struct Frame {
        var renderedNamespaces: [XMLNamespaceName: String]
        var namespaces: [XMLNamespaceName: String]
    }

    mutating func callAsFunction(document: XMLElementNode) throws {
        let frame = Frame(
            renderedNamespaces: [.default: ""],
            namespaces: [.default: ""]
        )

        try process(frame: frame, element: document)
    }

    private mutating func process(
        frame: Frame,
        node: XMLNode
    ) throws {
        switch node.switcher {
        case .element(let element):
            try process(frame: frame, element: element)
        case .text:
            break
        }
    }

    private mutating func process(
        frame: Frame,
        element: XMLElementNode
    ) throws {
        var frame = frame
        for (namespace, uri) in element.namespaces {
            frame.namespaces[namespace] = uri
        }

        var renderingNamespaceDictionary: [XMLNamespaceName: XMLNamespaceAttribute] = [:]

        func addOutputNamespace(name: XMLNamespaceName, uri: String) {
            if let rendered = frame.renderedNamespaces[name],
               rendered == uri
            {
                return
            }

            if name == .default, uri.isEmpty {
                guard element.namespaces.contains(where: { $0.key == .default }) else {
                    return
                }
            }

            renderingNamespaceDictionary[name] = XMLNamespaceAttribute(
                namespace: name, uri: uri
            )
        }

        func addOutputNamespace(name: XMLNameWithURI) {
            addOutputNamespace(name: name.name.namespace, uri: name.uri)
        }

        let name = try element.name.withURI(namespaces: frame.namespaces)
        addOutputNamespace(name: name)

        var attributes: [XMLAttributeWithURI] = try element.attributes.map { (name, value) in
            let attribute = XMLAttribute(name: name, value: value)
            return try attribute.withURI(namespaces: frame.namespaces)
        }
        for attribute in attributes {
            addOutputNamespace(name: attribute.name)
        }

        let renderingNamespaces = renderingNamespaceDictionary
            .map { $1 }
            .sorted { $0.namespace < $1.namespace }

        // defaultが先頭
        for ns in renderingNamespaces {
            frame.renderedNamespaces[ns.namespace] = ns.uri
        }

        attributes.sort {
            XMLCanonicalization.compareAttributeNames($0.name, $1.name)
        }

        element.namespaces = OrderedDictionary(renderingNamespaces.map { ($0.namespace, $0.uri) }) { $1 }
        element.attributes = OrderedDictionary(attributes.map { ($0.name.name, $0.value) }) { $1 }

        for node in element.children {
            try process(frame: frame, node: node)
        }
    }
}
