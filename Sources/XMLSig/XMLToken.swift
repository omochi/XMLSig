public enum XMLToken: Equatable {
    case startElement(XMLStartElementToken)
    case text(String)
    case endElement(XMLName)
}
