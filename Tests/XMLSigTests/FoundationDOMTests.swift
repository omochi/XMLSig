import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import XCTest

final class FoundationDOMTests: XCTestCase {
    func testNamespaceAttribute() throws {
        let string = """
<aaa xmlns="http://aaa.com"
     xmlns:ns1="http://ns1.com"
>
</aaa>
"""
        let xml = try XMLDocument(xmlString: string, options: [])
        let aaa = try XCTUnwrap(xml.rootElement())
        do {
            let ns = try XCTUnwrap(aaa.namespaces?[safe: 0])
            XCTAssertEqual(ns.name, "")
            #if os(Linux)
            // なんと呼び出すだけでクラッシュする
//            XCTAssertEqual(ns.prefix, "")
            #else
            XCTAssertEqual(ns.prefix, "")
            #endif
            XCTAssertEqual(ns.localName, "")
            XCTAssertEqual(ns.stringValue, "http://aaa.com")
        }
        do {
            let ns = try XCTUnwrap(aaa.namespaces?[safe: 1])
            XCTAssertEqual(ns.name, "ns1")
            #if os(Linux)
            // LinuxとMacで結果が違う
            XCTAssertEqual(ns.prefix, "ns1")
            XCTAssertEqual(ns.localName, "")
            #else
            XCTAssertEqual(ns.prefix, "")
            XCTAssertEqual(ns.localName, "ns1")
            #endif
            XCTAssertEqual(ns.stringValue, "http://ns1.com")
        }
    }


    func testXMLAttribute() throws {
        let string = """
<aaa xmlns:ns1="http://ns1.com"
     attr1="val1"
     ns1:attr2="val2"
>
</aaa>
"""
        let xml = try XMLDocument(xmlString: string, options: [])
        let aaa = try XCTUnwrap(xml.rootElement())

        let attributes = try XCTUnwrap(aaa.attributes)
        XCTAssertEqual(attributes.count, 2)

        XCTAssertEqual(attributes[safe: 0]?.name, "attr1")
        #if os(Linux)
        // クラッシュする
//        XCTAssertEqual(attributes[safe: 0]?.prefix, "")
        #else
        XCTAssertEqual(attributes[safe: 0]?.prefix, "")
        #endif
        XCTAssertEqual(attributes[safe: 0]?.localName, "attr1")
        XCTAssertEqual(attributes[safe: 0]?.stringValue, "val1")

        XCTAssertEqual(attributes[safe: 1]?.name, "ns1:attr2")
        XCTAssertEqual(attributes[safe: 1]?.prefix, "ns1")
        XCTAssertEqual(attributes[safe: 1]?.localName, "attr2")
        XCTAssertEqual(attributes[safe: 1]?.stringValue, "val2")
    }

}
