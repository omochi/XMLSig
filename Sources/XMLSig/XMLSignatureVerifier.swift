import Foundation
import Cryptor

public struct XMLSignatureVerifier {
    public init() {}
    
    public func verify(xml: Data) throws {
        let parser = XMLParser()
        let document = try parser.parse(xml: xml)
        return try verify(document: document)
    }

    public func verify(document: XMLElementNode) throws {
        let v = Verifier()
        return try v(document: document)
    }
}

private struct Verifier {
    func callAsFunction(document: XMLElementNode) throws {
        func walk(node: XMLNode) throws {
            if let element = node as? XMLElementNode,
               isSignatureElement(element, name: "Signature")
            {
                try process(signatureElement: element)
            }

            if let parent = node as? XMLParentNode {
                for c in parent.children {
                    try walk(node: c)
                }
            }
        }

        try walk(node: document)
    }

    private func process(signatureElement: XMLElementNode) throws {
        // 署名検証操作用の複製を作る。
        guard let document = signatureElement.root.copy() as? XMLElementNode else {
            throw MessageError("document is not element")
        }
        // 複製先における署名ノードを取得する。
        guard let signatureElement = document[signatureElement.path] as? XMLElementNode else {
            throw MessageError("signatureElement is not element")
        }

        try verify(document: document, signatureElement: signatureElement)
    }

    private func verify(document: XMLElementNode, signatureElement: XMLElementNode) throws {
        guard let signedInfo = signatureElement.children.first(where: {
            self.isSignatureElement($0, name: "SignedInfo")
        }) as? XMLElementNode else {
            throw MessageError("no SignedInfo element")
        }

        guard let reference = signedInfo.children.first(where: {
            self.isSignatureElement($0, name: "Reference")
        }) as? XMLElementNode else {
            throw MessageError("no Reference element")
        }

        guard let referenceURI = reference.attributes[.init(namespace: .default, name: "URI")] else {
            throw MessageError("no URI attribute")
        }

        guard referenceURI.hasPrefix("#") else {
            throw MessageError("# prefixed URI is only supported")
        }
        var findID = referenceURI
        findID.removeFirst()
        guard let target = document.findElement(where: { (element) in
            element.attributes[.init(namespace: .default, name: "ID")] == findID
        }) else {
            throw MessageError("target not found: \(findID)")
        }

        guard let transformsElement = reference.children.first(where: {
            self.isSignatureElement($0, name: "Transforms")
        }) as? XMLElementNode else {
            throw MessageError("no Transforms element")
        }

        for transform in transformsElement.children.compactMap({ (node) -> XMLElementNode? in
            guard let element = node as? XMLElementNode,
                  self.isSignatureElement(element, name: "Transform") else { return nil }
            return element
        }) {
            guard let algorithm = transform.attributes[.init(namespace: .default, name: "Algorithm")] else {
                throw MessageError("no Algorithm attribute")
            }
            switch algorithm {
            case XMLSignature.Transforms.envelopedSignatureURI:
                try envelopedSignatureTransform(target: target, transform: transform)
            case XMLCanonicalization.exclusiveCanonicalizationURI:
                let canonicalizer = XMLExclusiveCanonicalizer()
                try canonicalizer.canonicalize(document: target)
            default:
                throw MessageError("unknown transform algorithm: \(algorithm)")
            }
        }

        let digestSource = target.description.data(using: .utf8)!

        guard let digestMethodElement = reference.children.first(where: {
            self.isSignatureElement($0, name: "DigestMethod")
        }) as? XMLElementNode else {
            throw MessageError("no DigestMethod element")
        }

        guard let digestAlgorithm = digestMethodElement.attributes[.init(namespace: .default, name: "Algorithm")] else {
            throw MessageError("no Algorithm attribute")
        }

        let computedDigest: Data = try {
            switch digestAlgorithm {
            case XMLSignature.DigestMethods.sha1URI:
                let d = Digest(using: .sha1)
                guard let bytes = d.update(data: digestSource)?.final() else {
                    throw MessageError("failed to compute sha1")
                }
                return Data(bytes)
            case XMLSignature.DigestMethods.sha256URI:
                let d = Digest(using: .sha256)
                guard let bytes = d.update(data: digestSource)?.final() else {
                    throw MessageError("failed to compute sha256")
                }
                return Data(bytes)
            default:
                throw MessageError("unknown digest algorithm: \(digestAlgorithm)")
            }
        }()

        guard let digestValueElement = reference.children.first(where: {
            self.isSignatureElement($0, name: "DigestValue")
        }) as? XMLElementNode else {
            throw MessageError("no DigestValue element")
        }
        let digestValueString = digestValueElement.children.map { $0.description }.joined()

        guard let expectedDigest = Data(base64Encoded: digestValueString) else {
            throw MessageError("broken base64 value: \(digestValueString)")
        }

        guard computedDigest == expectedDigest else {
            throw MessageError("computed digest unmatched to declared digest")
        }
    }

    private func envelopedSignatureTransform(target: XMLElementNode, transform: XMLElementNode) throws {
        guard target.root === transform.root else {
            throw MessageError("unrelated target and transform")
        }

        guard let signature = transform.findAncestor(where: {
            isSignatureElement($0, name: "Signature")
        }) else {
            throw MessageError("no Signature element")
        }

        signature.removeFromParent()
    }

    private func isSignatureElement(_ node: XMLNode, name: String) -> Bool {
        guard let element = node as? XMLElementNode else { return false }
        return isSignatureElement(element, name: name)
    }

    private func isSignatureElement(_ element: XMLElementNode, name: String) -> Bool {
        if let elementName = element.resolvedName,
           elementName.uri == XMLSignature.version_1_0_URI,
           elementName.name.name == name
        {
            return true
        }
        return false
    }
}
