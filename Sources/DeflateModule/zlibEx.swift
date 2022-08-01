import Foundation
import CDeflateModule

extension z_stream {
    mutating func deflateBound(input: Int) -> Int {
        let bound = CDeflateModule.deflateBound(
            &self,
            UInt(input)
        )
        return Int(bound)
    }

    mutating func setInput(_ buffer: UnsafeRawBufferPointer?) {
        guard let buffer = buffer?.bindMemory(to: UInt8.self) else {
            self.next_in = nil
            self.avail_in = 0
            return
        }

        self.next_in = UnsafeMutableBufferPointer(mutating: buffer).baseAddress
        self.avail_in = UInt32(buffer.count)
    }

    mutating func setOutput(_ buffer: UnsafeMutableRawBufferPointer?) {
        guard let buffer = buffer?.bindMemory(to: UInt8.self) else {
            self.next_out = nil
            self.avail_out = 0
            return
        }

        self.next_out = buffer.baseAddress
        self.avail_out = UInt32(buffer.count)
    }

    mutating func deflate(
        input: inout Data,
        output: inout Data,
        flush: Int32
    ) -> ZLibError {
        let (read, write, error) = input.withUnsafeBytes { (input) in
            output.withUnsafeMutableBytes { (output) in
                self.deflate(
                    input: input,
                    output: output,
                    flush: flush
                )
            }
        }
        precondition(read <= input.count, "invalid read size: \(read), max=\(input.count)")

        let position = input.startIndex + read
        input = Data(input[position...])
        output.count = write
        return error
    }

    mutating func deflate(
        input: UnsafeRawBufferPointer,
        output: UnsafeMutableRawBufferPointer,
        flush: Int32
    ) -> (read: Int, write: Int, error: ZLibError) {
        self.setInput(input)
        self.setOutput(output)

        let error = ZLibError(
            rawValue: CDeflateModule.deflate(&self, flush)
        )
        let read = input.count - Int(self.avail_in)
        let write = output.count - Int(self.avail_out)

        self.setInput(nil)
        self.setOutput(nil)

        return (
            read: read,
            write: write,
            error: error
        )
    }

    mutating func inflate(
        input: inout Data,
        output: inout Data,
        flush: Int32
    ) -> ZLibError {
        let (read, write, error) = input.withUnsafeBytes { (input) in
            output.withUnsafeMutableBytes { (output) in
                self.inflate(
                    input: input,
                    output: output,
                    flush: flush
                )
            }
        }
        precondition(read <= input.count, "invalid read size: \(read), max=\(input.count)")

        let position = input.startIndex + read
        input = Data(input[position...])
        output.count = write
        return error
    }

    mutating func inflate(
        input: UnsafeRawBufferPointer,
        output: UnsafeMutableRawBufferPointer,
        flush: Int32
    ) -> (read: Int, write: Int, error: ZLibError) {
        self.setInput(input)
        self.setOutput(output)

        let error = ZLibError(
            rawValue: CDeflateModule.inflate(&self, flush)
        )
        let read = input.count - Int(self.avail_in)
        let write = output.count - Int(self.avail_out)

        self.setInput(nil)
        self.setOutput(nil)

        return (
            read: read,
            write: write,
            error: error
        )
    }
}
