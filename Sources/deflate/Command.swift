import Foundation
import DeflateModule

struct Command {
    struct UsageError: Error {
        var message: String?

        init(_ message: String? = nil) {
            self.message = message
        }
    }

    var action: DeflateApp.Action
    var format: DeflateModule.Format
    var file: URL?

    static func parse() throws -> Command {
        var action: DeflateApp.Action = .compression
        var format: DeflateModule.Format = .zlib
        var file: URL? = nil

        let args = CommandLine.arguments
        var index = 1
        while index < args.count {
            var arg = args[index]
            if arg.hasPrefix("-") {
                arg.removeFirst()
                for opt in arg {
                    switch opt {
                    case "h":
                        throw UsageError()
                    case "c":
                        action = .compression
                    case "d":
                        action = .decompression
                    case "z":
                        format = .zlib
                    case "g":
                        format = .gzip
                    case "r":
                        format = .raw
                    default:
                        throw UsageError("unknown option: \(opt)")
                    }
                }
                index += 1
            } else {
                break
            }
        }

        if index < args.count {
            file = URL(fileURLWithPath: args[index])
            index += 1
        }

        if index < args.count {
            throw UsageError("invalid argument")
        }

        return Command(
            action: action,
            format: format,
            file: file
        )
    }
}
