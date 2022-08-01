import Foundation
import DeflateModule

extension Stream {
    func checkError() throws {
        if streamStatus == .error,
           let error = streamError {
            throw error
        }
    }
}

extension InputStream {
    func read(maxLength: Int) -> Data {
        var buffer = Data(count: maxLength)
        let size = buffer.withUnsafeMutableBytes { (buffer) -> Int in
            let buffer = buffer.bindMemory(to: UInt8.self)
            return self.read(buffer.baseAddress!, maxLength: buffer.count)
        }
        buffer.count = size
        return buffer
    }
}

extension OutputStream {
    func write(data: Data) -> Int {
        return data.withUnsafeBytes { (buffer) in
            let buffer = buffer.bindMemory(to: UInt8.self)
            guard let pointer = buffer.baseAddress else {
                return 0
            }
            return self.write(pointer, maxLength: buffer.count)
        }
    }

    func writeAll(data: Data) throws {
        let size = write(data: data)
        guard size == data.count else {
            throw MessageError("failed to write: expect=\(data.count), actual=\(size)")
        }
    }
}
