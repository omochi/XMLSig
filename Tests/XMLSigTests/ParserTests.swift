import XCTest
import XMLSig

final class ParserTests: XCTestCase {
    func testMin() throws {
        let doc = try parse(xml: """
<doc></doc>
"""
        )
        XCTAssertEqual(doc.name, XMLName(namespace: .default, name: "doc"))
        XCTAssertEqual(doc.children.count, 0)
        XCTAssertNil(doc.parent)
    }

    func testTree() throws {
        let doc = try parse(xml: """
<doc>
  <aaa>
    <bbb/>
  </aaa>
  <ccc/>
</doc>
"""
        )
        XCTAssertEqual(doc.name, XMLName(namespace: .default, name: "doc"))
        XCTAssertEqual(doc.children.count, 5)
        XCTAssertEqual((doc.children[safe: 0] as? XMLTextNode)?.text, "\n  ")

        do {
            let aaa = try XCTUnwrap(doc.children[safe: 1] as? XMLElementNode)
            XCTAssertIdentical(aaa.parent, doc)
            XCTAssertEqual(
                aaa.startToken,
                XMLStartElementToken(name: XMLName(namespace: .default, name: "aaa"))
            )

            XCTAssertEqual(aaa.children.count, 3)
            XCTAssertEqual((aaa.children[safe: 0] as? XMLTextNode)?.text, "\n    ")
            XCTAssertEqual(
                (aaa.children[safe: 1] as? XMLElementNode)?.startToken,
                XMLStartElementToken(name: XMLName(namespace: .default, name: "bbb"))
            )
            XCTAssertEqual((aaa.children[safe: 2] as? XMLTextNode)?.text, "\n  ")
        }

        XCTAssertEqual((doc.children[safe: 2] as? XMLTextNode)?.text, "\n  ")
        XCTAssertEqual(
            (doc.children[safe: 3] as? XMLElementNode)?.startToken,
            XMLStartElementToken(name: XMLName(namespace: .default, name: "ccc"))
        )
        XCTAssertEqual((doc.children[safe: 4] as? XMLTextNode)?.text, "\n")
    }

    private func parse(xml: String) throws -> XMLElementNode {
        let parser = XMLParser()
        return try parser.parse(xml: xml.data(using: .utf8)!)
    }
}
