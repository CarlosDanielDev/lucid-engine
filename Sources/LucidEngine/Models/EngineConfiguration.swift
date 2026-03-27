public struct EngineConfiguration: Sendable, Equatable {

    public let defaultDepth: Int
    public let threadCount: Int
    public let hashSizeMB: Int
    public let timeoutSeconds: Double

    public static let `default` = try! EngineConfiguration(
        defaultDepth: 18,
        threadCount: 1,
        hashSizeMB: 64
    )

    public init(
        defaultDepth: Int = 18,
        threadCount: Int = 1,
        hashSizeMB: Int = 64,
        timeoutSeconds: Double = 5.0
    ) throws {
        guard (1...100).contains(defaultDepth) else {
            throw EngineError.invalidConfiguration("defaultDepth must be 1...100, got \(defaultDepth)")
        }
        guard (1...64).contains(threadCount) else {
            throw EngineError.invalidConfiguration("threadCount must be 1...64, got \(threadCount)")
        }
        guard (1...4096).contains(hashSizeMB) else {
            throw EngineError.invalidConfiguration("hashSizeMB must be 1...4096, got \(hashSizeMB)")
        }
        guard timeoutSeconds > 0 else {
            throw EngineError.invalidConfiguration("timeoutSeconds must be > 0, got \(timeoutSeconds)")
        }
        self.defaultDepth = defaultDepth
        self.threadCount = threadCount
        self.hashSizeMB = hashSizeMB
        self.timeoutSeconds = timeoutSeconds
    }
}
