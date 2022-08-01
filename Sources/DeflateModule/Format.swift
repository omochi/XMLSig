public enum Format {
    case zlib
    case gzip
    case raw

    var windowBits: Int32 {
        switch self {
        case .zlib:
            return 15
        case .gzip:
            return 16 + 15
        case .raw:
            return -15
        }
    }
}
