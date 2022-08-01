import Collections

/*
 ホワイトスペースを含むテキスト情報を完全に保存できるDOM実装。
 文字列化した時のアトリビュートとテキストの描画はCanonicalization規格に従う。
 */
public class XMLNode: _XMLNodeProtocol, TextOutputStreamable, CustomStringConvertible {
    public enum Switcher {
        case element(XMLElementNode)
        case text(XMLTextNode)
    }

    init() {}
    weak var _parent: XMLParentNode?

    public var parent: XMLParentNode? {
        _parent
    }

    public var root: XMLNode {
        guard let parent = _parent else {
            return self
        }
        return parent.root
    }

    public var switcher: Switcher {
        fatalError("unimplemented")
    }

    public func _copy() -> XMLNode {
        fatalError("unimplemented")
    }

    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        fatalError("unimplemented")
    }

    func resolveURILocally(for namespace: XMLNamespaceName) -> String? { return nil }

    public func removeFromParent() {
        guard let parent = self.parent else { return }
        parent.children.removeAll { $0 === self }
    }

    public var description: String {
        var s = ""
        write(to: &s)
        return s
    }

    public func resolveURI(for namespace: XMLNamespaceName) -> String? {
        if let uri = resolveURILocally(for: namespace) { return uri }
        return parent?.resolveURI(for: namespace)
    }

    public func findNode(where predicate: (XMLNode) throws -> Bool) rethrows -> XMLNode? {
        if try predicate(self) { return self }
        return nil
    }

    public func findElement(where predicate: (XMLElementNode) throws -> Bool) rethrows -> XMLElementNode? {
        return try self.findNode { (node) in
            guard let element = node as? XMLElementNode else {
                return false
            }
            return try predicate(element)
        } as? XMLElementNode
    }

    public func findAncestor(where predicate: (XMLNode) throws -> Bool) rethrows -> XMLNode? {
        var _node: XMLNode? = self
        while let node = _node {
            if try predicate(node) { return node }
            _node = node.parent
        }
        return nil
    }

    public var path: XMLNodePath {
        guard let parent = self.parent,
              let index = parent.children.firstIndex(where: { $0 === self }) else
        {
            return []
        }
        var path = parent.path
        path.append(.init(rawValue: index))
        return path
    }

    public subscript(path: XMLNodePath) -> XMLNode? {
        get {
            var path = path

            if path.isEmpty {
                return self
            }

            let item = path.removeFirst()
            let index = item.rawValue

            guard let parent = self as? XMLParentNode,
                  0 <= index, index < parent.children.count else
            {
                return nil
            }

            let next = parent.children[index]

            return next[path]
        }
    }
}

/*
 copyの型をSelfにするためのハック
 */
public protocol _XMLNodeProtocol: AnyObject {
    func _copy() -> XMLNode
    func copy() -> Self
}

extension _XMLNodeProtocol {
    public func copy() -> Self {
        _copy() as! Self
    }
}

public class XMLParentNode: XMLNode {
    override init() {
        children = XMLNodeChildrenProperty()
        super.init()
        children._parent = self
    }
    public let children: XMLNodeChildrenProperty

    public override func findNode(where predicate: (XMLNode) throws -> Bool) rethrows -> XMLNode? {
        if try predicate(self) { return self }

        for c in children {
            if let result = try c.findNode(where: predicate) {
                return result
            }
        }

        return nil
    }
}

public final class XMLElementNode: XMLParentNode {
    public init(
        name: XMLName,
        namespaces: OrderedDictionary<XMLNamespaceName, String> = [:],
        attributes: OrderedDictionary<XMLName, String> = [:]
    ) {
        self.name = name
        self.namespaces = namespaces
        self.attributes = attributes
        super.init()
    }

    public convenience init(
        startToken token: XMLStartElementToken
    ) {
        self.init(
            name: token.name,
            namespaces: token.namespaces,
            attributes: token.attributes
        )
    }

    public override var switcher: XMLNode.Switcher { .element(self) }

    public var name: XMLName
    public var namespaces: OrderedDictionary<XMLNamespaceName, String>
    public var attributes: OrderedDictionary<XMLName, String>

    public override func _copy() -> XMLNode {
        let node = XMLElementNode(startToken: startToken)
        for c in children {
            node.children.append(c.copy())
        }
        return node
    }

    public var startToken: XMLStartElementToken {
        XMLStartElementToken(
            name: name,
            namespaces: namespaces,
            attributes: attributes
        )
    }

    override func resolveURILocally(for namespace: XMLNamespaceName) -> String? {
        return namespaces[namespace]
    }

    public var resolvedName: XMLNameWithURI? {
        guard let uri = resolveURI(for: name.namespace) else { return nil }
        return name.withURI(uri: uri)
    }

    public override func write<Target>(to target: inout Target) where Target : TextOutputStream {
        let token = self.startToken
        target.write(token.description)
        for node in children {
            node.write(to: &target)
        }
        target.write("</\(token.name)>")
    }
}

public final class XMLTextNode: XMLNode {
    public init(
        text: String = ""
    ) {
        self.text = text
        super.init()
    }

    public override var switcher: XMLNode.Switcher { .text(self) }

    public var text: String

    public override func _copy() -> XMLNode {
        XMLTextNode(text: text)
    }

    public override func write<Target>(to target: inout Target) where Target : TextOutputStream {
        let text = XMLCanonicalization.escapeText(text)
        target.write(text)
    }
}
