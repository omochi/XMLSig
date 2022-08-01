import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Collections

public struct XMLTokenizer {
    #if canImport(FoundationXML)
    private typealias FXMLParser = FoundationXML.XMLParser
    private typealias FXMLParserDelegate = FoundationXML.XMLParserDelegate
    #else
    private typealias FXMLParser = Foundation.XMLParser
    private typealias FXMLParserDelegate = Foundation.XMLParserDelegate
    #endif

    public init() {}

    public func tokenize(xml: Data) throws -> [XMLToken] {
        var tokens: [XMLToken] = []
        let delegate = Delegate { (token) in
            tokens.append(token)
        }
        let parser = FXMLParser(data: xml)
        parser.delegate = delegate
        parser.parse()

        if let error = delegate.error {
            throw error
        }

        return tokens
    }

    private final class Delegate: NSObject, FXMLParserDelegate {
        var outputToken: (XMLToken) -> Void
        var error: Error?

        init(
            outputToken: @escaping (XMLToken) -> Void
        ) {
            self.outputToken = outputToken
        }

        func parser(_ parser: FXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            let name = XMLName(from: elementName)
            var namespaces: OrderedDictionary<XMLNamespaceName, String> = [:]
            var attributes: OrderedDictionary<XMLName, String> = [:]

            for (_attribute, value) in attributeDict {
                let attribute = XMLName(from: _attribute)

                if attribute.namespace == .default, attribute.name == "xmlns" {
                    namespaces[.default] = value
                } else if attribute.namespace == .xmlns {
                    namespaces[.init(attribute.name)] = value
                } else {
                    attributes[attribute] = value
                }
            }

            /*
             パーサから記述順序が得られないのでトークナイザ固有の正規化を行う。
             XMLCanonicalizationでは別の順序が必要なので注意する。
             */
            namespaces.sort { $0.key < $1.key }
            attributes.sort { $0.key < $1.key }

            let element = XMLStartElementToken(
                name: name,
                namespaces: namespaces,
                attributes: attributes
            )
            outputToken(.startElement(element))
        }

        func parser(_ parser: FXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            let name = XMLName(from: elementName)
            outputToken(.endElement(name))
        }

        func parser(_ parser: FXMLParser, foundCharacters string: String) {
            outputToken(.text(string))
        }

        /*
         Mac版ではこのメソッドを実装するかどうかで挙動が変わるが、
         Linux版では必ずこのメソッドが呼ばれてしまうので、それに合わせる。

         CDATAコンテンツはドキュメントのエンコードでデコードする必要があるが、
         パーサが読み取ったエンコード宣言を取得する方法が無いので、
         UTF-8で決め打ちする。

         UTF-8ではないドキュメントでCDATAコンテンツが含まれていると処理できない。
         */
        func parser(_ parser: FXMLParser, foundCDATA CDATABlock: Data) {
            guard let text = String(data: CDATABlock, encoding: .utf8) else {
                self.error = MessageError("non utf-8 CDATA content is unsupported")
                parser.abortParsing()
                return
            }
            outputToken(.text(text))
        }

        func parser(_ parser: FXMLParser, parseErrorOccurred parseError: Error) {
            parser.abortParsing()
            self.error = parseError
        }
    }
}
