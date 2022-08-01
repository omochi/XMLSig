import XCTest
import XMLSig

public final class TokenizerTests: XCTestCase {
    func testTokenizer() throws {
        let xml = """
<aaa xmlns="http://default.com"
     xmlns:ns1="http://ns1.com"
     xx="1"
     ns1:yy="2">
  <ns1:bbb />
</aaa>
"""
        let tokenizer = XMLTokenizer()
        let tokens = try tokenizer.tokenize(xml: xml.data(using: .utf8)!)

        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(
            tokens[safe: 0],
            .startElement(
                XMLStartElementToken(
                    name: .init(namespace: .default, name: "aaa"),
                    namespaces: [
                        .default: "http://default.com",
                        .init("ns1"): "http://ns1.com"
                    ],
                    attributes: [
                        .init(namespace: .default, name: "xx"): "1",
                        .init(namespace: .init("ns1"), name: "yy"): "2"
                    ]
                )
            )
        )
        XCTAssertEqual(
            tokens[safe: 1],
            .text("\n  ")
        )
        XCTAssertEqual(
            tokens[safe: 2],
            .startElement(
                XMLStartElementToken(
                    name: .init(namespace: .init("ns1"), name: "bbb")
                )
            )
        )
        XCTAssertEqual(
            tokens[safe: 3],
            .endElement(.init(namespace: .init("ns1"), name: "bbb"))
        )
        XCTAssertEqual(
            tokens[safe: 4],
            .text("\n")
        )
        XCTAssertEqual(
            tokens[safe: 5],
            .endElement(.init(namespace: .default, name: "aaa"))
        )
    }
}
