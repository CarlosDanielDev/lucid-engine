internal import CStockfish

public actor LucidEngine {

    public private(set) var isInitialized = false

    public init() {}

    /// Idempotent. Safe to call multiple times.
    public func start() throws {
        guard !isInitialized else { return }
        let status = sf_init()
        guard status == SF_OK || status == SF_ERR_ALREADY_INIT else {
            throw EngineError.initializationFailed
        }
        isInitialized = true
    }

    /// Callers must call shutdown() explicitly before releasing the engine.
    public func shutdown() {
        guard isInitialized else { return }
        sf_cleanup()
        isInitialized = false
    }
}
