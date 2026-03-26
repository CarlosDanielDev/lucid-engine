public enum EngineError: Error, Sendable, Equatable {
    case initializationFailed
    case engineNotRunning
    case invalidConfiguration(String)
    case invalidDepth(Int)
    case invalidFEN
}
