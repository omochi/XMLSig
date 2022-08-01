import Foundation
import DeflateModule

@main
public struct DeflateApp {
    enum Action {
        case compression
        case decompression
    }

    public static func main() throws {
        try DeflateApp()()
    }

    private func printUsage() {
        let name = CommandLine.arguments[0]
        print("""
USAGE: \(name) [-hcdzgr] <input>

OPTIONS:
  -h: help
  -c: compress (default)
  -d: decompress
  -z: zlib (default)
  -g: gzip
  -r: raw
""")
    }

    init() {

    }

    let chunkSize = 1024

    func callAsFunction() throws {
        let command: Command
        do {
            command = try Command.parse()
        } catch let error as Command.UsageError {
            if let message = error.message {
                print(message)
            }
            printUsage()
            return
        }

        let reader = self.reader(file: command.file)
        try reader.checkError()
        let deflate = try self.deflate(action: command.action, format: command.format)

        let writer = OutputStream(url: URL(fileURLWithPath: "/dev/stdout"), append: true)!
        writer.open()
        try writer.checkError()

        func drain() throws {
            while true {
                let chunk = try deflate.read()
                guard chunk.count > 0 else { break }
                try writer.writeAll(data: chunk)
                try writer.checkError()
            }
        }

        while true {
            let input = reader.read(maxLength: chunkSize)
            try reader.checkError()
            if input.isEmpty {
                break
            }
            try deflate.write(data: input)
            try drain()
        }

        try deflate.writeEnd()
        try drain()

        writer.close()
        reader.close()
    }

    func reader(file: URL?) -> InputStream {
        let file = file ?? URL(fileURLWithPath: "/dev/stdin")
        let stream = InputStream(url: file)!
        stream.open()
        return stream
    }

    func deflate(action: Action, format: Format) throws -> StreamProtocol {
        switch action {
        case .compression:
            return try CompressionStream(format: format)
        case .decompression:
            return try DecompressionStream(format: format)
        }
    }
}

