public enum XMLCanonicalization {
    public static let exclusiveCanonicalizationURI = "http://www.w3.org/2001/10/xml-exc-c14n#"

    public static func compareAttributeNames(_ a: XMLNameWithURI, _ b: XMLNameWithURI) -> Bool {
        if a.uri != b.uri {
            return a.uri < b.uri
        }
        return a.name.name < b.name.name
    }

    public static func esacpeAttributeValue(_ value: String) -> String {
        return EscapeAttributeValue()(value)
    }

    private struct EscapeAttributeValue {
        private static let list: [(String, String)] = [
            ("&", "&amp;"),
            ("<", "&lt;"),
            ("\"", "&quot;"),
            ("\u{09}", "&#x9;"),
            ("\u{0D}", "&#xD;"),
            ("\u{0A}", "&#xA;")
        ]

        func callAsFunction(_ string: String) -> String {
            var s = string
            for item in Self.list {
                s = s.replacingOccurrences(of: item.0, with: item.1)
            }
            return s
        }
    }

    public static func escapeText(_ value: String) -> String {
        return EscapeText()(value)
    }

    private struct EscapeText {
        private static let list: [(String, String)] = [
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("\u{0D}", "&#xD;")
        ]

        func callAsFunction(_ string: String) -> String {
            var s = string
            for item in Self.list {
                s = s.replacingOccurrences(of: item.0, with: item.1)
            }
            return s
        }
    }
}
