import Foundation
import CDeflateModule

public final class DecompressionStream: StreamProtocol {
    private var stream: z_stream
    private var input: Data

    public init(format: Format) throws {
        stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil

        let windowBits = format.windowBits

        let error = ZLibError(
            rawValue: CDeflateModule_inflateInit2(
                &stream,
                windowBits
            )
        )
        guard error == .ok else {
            throw MessageError("failed to inflateInit2: \(error)")
        }

        input = Data()
    }

    deinit {
        inflateEnd(&stream)
    }

    public func write(data: Data) {
        input.append(data)
    }

    public func writeEnd() {}

    public func read() throws -> Data {
        if input.isEmpty { return Data() }

        var buffer = Data(count: 16 * 1024)
        let error = stream.inflate(
            input: &input,
            output: &buffer,
            flush: Z_NO_FLUSH
        )
        guard error == .ok || error == .streamEnd else {
            throw MessageError("inflate failed: \(error)")
        }
        return buffer
    }
}
