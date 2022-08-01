import XCTest
import XMLSig

final class BasicTests: XCTestCase {
    func testXMLNamespace() {
        let a = XMLNamespaceName("ns1")
        XCTAssertEqual(a.rawValue, "ns1")
        XCTAssertNotEqual(a, .default)

        let b = XMLNamespaceName("ns2")
        XCTAssertEqual(b.rawValue, "ns2")
        XCTAssertNotEqual(b, .default)
        XCTAssertNotEqual(a, b)

        let empty = XMLNamespaceName("")
        XCTAssertEqual(empty.rawValue, "")
        XCTAssertEqual(empty, .default)

        let def = XMLNamespaceName.default
        XCTAssertEqual(def.rawValue, "")
    }

    func testXMLName() throws {
        let a = XMLName(from: "aaa")
        XCTAssertEqual(a.namespace, .default)
        XCTAssertEqual(a.name, "aaa")
        XCTAssertEqual(a.description, "aaa")

        let b = XMLName(from: "ns1:bbb")
        XCTAssertEqual(b.namespace, .init("ns1"))
        XCTAssertEqual(b.name, "bbb")
        XCTAssertEqual(b.description, "ns1:bbb")
    }

    func testXMLNamespaceAttributeString() throws {
        XCTAssertEqual(
            XMLNamespaceAttribute(namespace: .default, uri: "http://aaa.com").description,
            #"xmlns="http://aaa.com""#
        )
        XCTAssertEqual(
            XMLNamespaceAttribute(namespace: .init("ns1"), uri: "http://ns1.com").description,
            #"xmlns:ns1="http://ns1.com""#
        )
    }
}
