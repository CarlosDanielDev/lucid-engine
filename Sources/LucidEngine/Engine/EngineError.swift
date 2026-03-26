public enum EngineError: Error, Sendable {
    case initializationFailed
    case notInitialized
    case invalidDepth(Int)
    case invalidFEN
}
