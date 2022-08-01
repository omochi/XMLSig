import Foundation

public final class XMLNodeChildrenProperty: Collection {
    public typealias Element = XMLNode
    public typealias Index = Array<Element>.Index

    weak var _parent: XMLParentNode?
    var _elements: [Element]

    public init() {
        _parent = nil
        _elements = []
    }

    public var elements: [Element] {
        _read { yield _elements }
        set {
            replaceSubrange(startIndex..<endIndex, with: newValue)
        }
    }

    public var startIndex: Index { _elements.startIndex }
    public var endIndex: Index { _elements.endIndex }

    public func index(after i: Index) -> Index {
        _elements.index(after: i)
    }

    public subscript(position: Index) -> XMLNode {
        _read {
            yield _elements[position]
        }
    }

    public func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        let removed = Array(_elements[subrange])
        _elements.replaceSubrange(subrange, with: newElements)
        for node in removed {
            node._parent = nil
        }
        for node in newElements {
            node._parent = _parent
        }
    }

    public func append(_ newElement: Element) { insert(newElement, at: endIndex) }
    public func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        for e in newElements {
            append(e)
        }
    }
    public func insert(_ newElement: Element, at i: Index) {
        replaceSubrange(i..<i, with: CollectionOfOne(newElement))
    }
    public func insert<S>(contentsOf newElements: S, at i: Index) where S : Collection, Element == S.Element {
        replaceSubrange(i..<i, with: newElements)
    }
    public func remove(at i: Index) -> Element {
        let result = _elements[i]
        replaceSubrange(i..<index(after: i), with: EmptyCollection())
        return result
    }
    public func removeSubrange(_ bounds: Range<Index>) {
        replaceSubrange(bounds, with: EmptyCollection())
    }
    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        var indices: [Index] = []
        for (i, e) in _elements.enumerated() {
            if try shouldBeRemoved(e) {
                indices.append(i)
            }
        }
        for i in indices.reversed() {
            _ = remove(at: i)
        }
    }
}
