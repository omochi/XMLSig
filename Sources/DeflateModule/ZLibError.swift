import Foundation
import CDeflateModule

public struct ZLibError: Error, RawRepresentable, CustomStringConvertible {
    public var rawValue: Int32

    public init(
        rawValue: Int32
    ) {
        self.rawValue = rawValue
    }

    public var description: String {
        switch rawValue {
        case Z_OK: return "Z_OK"
        case Z_STREAM_END: return "Z_STREAM_END"
        case Z_NEED_DICT: return "Z_NEED_DICT"
        case Z_ERRNO: return "Z_ERRNO"
        case Z_STREAM_ERROR: return "Z_STREAM_ERROR"
        case Z_DATA_ERROR: return "Z_DATA_ERROR"
        case Z_MEM_ERROR: return "Z_MEM_ERROR"
        case Z_BUF_ERROR: return "Z_BUF_ERROR"
        case Z_VERSION_ERROR: return "Z_VERSION_ERROR"
        default: return rawValue.description
        }
    }

    public static let ok: ZLibError = .init(rawValue: Z_OK)
    public static let streamEnd: ZLibError = .init(rawValue: Z_STREAM_END)
}
