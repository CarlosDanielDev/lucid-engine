internal import CStockfish

public actor LucidEngine {

    public let configuration: EngineConfiguration

    public private(set) var isRunning: Bool = false

    public init(configuration: EngineConfiguration = .default) {
        self.configuration = configuration
    }

    /// Start the engine. Calls `sf_init()` on the C side.
    /// Idempotent — calling on an already-running engine is a no-op.
    public func start() throws {
        guard !isRunning else { return }
        let status = sf_init()
        guard status == SF_OK || status == SF_ERR_ALREADY_INIT else {
            throw EngineError.initializationFailed
        }
        isRunning = true
    }

    /// Shut down the engine and release all C resources.
    /// Idempotent — calling on a stopped engine is a safe no-op.
    public func shutdown() {
        guard isRunning else { return }
        sf_cleanup()
        isRunning = false
    }

    /// Throws if the engine is not running. Call at the top of every operation method.
    func ensureRunning() throws {
        guard isRunning else {
            throw EngineError.engineNotRunning
        }
    }
}
