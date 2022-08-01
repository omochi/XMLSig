import Foundation
import CDeflateModule

public final class CompressionStream: StreamProtocol {
    private var stream: z_stream
    private var input: Data
    private var isInputEnded: Bool
    private var isOutputFinished: Bool

    public init(format: Format) throws {
        stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil

        let windowBits = format.windowBits

        let error = ZLibError(
            rawValue: CDeflateModule_deflateInit2(
                &stream,
                Z_DEFAULT_COMPRESSION,
                Z_DEFLATED,
                windowBits,
                8,
                Z_DEFAULT_STRATEGY
            )
        )
        guard error == .ok else {
            throw MessageError("failed to deflateInit2: \(error)")
        }

        input = Data()
        isInputEnded = false
        isOutputFinished = false
    }

    deinit {
        deflateEnd(&stream)
    }

    public func write(data: Data) {
        input.append(data)
    }

    public func writeEnd() {
        isInputEnded = true
    }

    public func read() throws -> Data {
        let bufferSize = stream.deflateBound(input: input.count) + 5
        var buffer = Data(count: bufferSize)

        if isInputEnded {
            if isOutputFinished { return Data() }

            let error = stream.deflate(
                input: &input,
                output: &buffer,
                flush: Z_FINISH
            )
            guard error == .streamEnd else {
                throw MessageError("deflate finish failed: \(error)")
            }
            isOutputFinished = true
        } else {
            if input.isEmpty { return Data() }

            let error = stream.deflate(
                input: &input,
                output: &buffer,
                flush: Z_SYNC_FLUSH
            )
            guard error == .ok else {
                throw MessageError("deflate failed: \(error)")
            }
        }

        return buffer
    }
}

