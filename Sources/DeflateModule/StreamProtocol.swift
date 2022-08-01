import Foundation

public protocol StreamProtocol {
    func write(data: Data) throws
    func writeEnd() throws
    func read() throws -> Data
}
