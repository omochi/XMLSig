import Foundation

public struct XMLParser {
    public init() {}
    
    public func parse(xml: Data) throws -> XMLElementNode {
        var p = Parser()
        return try p(xml: xml)
    }
}

private struct Parser {
    struct Frame {
        var element: XMLElementNode
    }

    let root: XMLElementNode
    var frames: [Frame]

    init() {
        root = XMLElementNode(name: XMLName(namespace: .default, name: ""))
        frames = [
            Frame(element: root)
        ]
    }

    mutating func callAsFunction(xml: Data) throws -> XMLElementNode {
        let tokenizer = XMLTokenizer()
        let tokens = try tokenizer.tokenize(xml: xml)

        for token in tokens {
            switch token {
            case .startElement(let token):
                let node = XMLElementNode(startToken: token)
                emit(node: node)
                frames.append(
                    Frame(element: node)
                )
            case .text(let text):
                let node = XMLTextNode(text: text)
                emit(node: node)
            case .endElement:
                frames.removeLast()
            }
        }

        guard let _node = root.children.first else {
            throw MessageError("no node")
        }
        guard let node = _node as? XMLElementNode else {
            throw MessageError("not element node")
        }
        node.removeFromParent()
        return node
    }

    private mutating func emit(node: XMLNode) {
        frames.last!.element.children.append(node)
    }
}
