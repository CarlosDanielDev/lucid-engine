import Testing
@testable import LucidEngine

// MARK: - LucidEngine Lifecycle Tests
//
// Issue #3: LucidEngine actor with init/start/stop lifecycle
//
// Serialized because sf_init/sf_cleanup are global C state.

@Suite("LucidEngine Lifecycle", .serialized)
struct LucidEngineLifecycleTests {

    // MARK: - Configuration

    @Test("Default configuration uses depth 18, 1 thread, 64 MB hash")
    func defaultConfiguration() {
        let config = EngineConfiguration.default
        #expect(config.defaultDepth == 18)
        #expect(config.threadCount == 1)
        #expect(config.hashSizeMB == 64)
    }

    @Test("Custom configuration stores values correctly")
    func customConfiguration() throws {
        let config = try EngineConfiguration(defaultDepth: 20, threadCount: 4, hashSizeMB: 128)
        #expect(config.defaultDepth == 20)
        #expect(config.threadCount == 4)
        #expect(config.hashSizeMB == 128)
    }

    @Test("Invalid defaultDepth throws invalidConfiguration")
    func invalidDepthThrows() {
        #expect(throws: EngineError.self) {
            _ = try EngineConfiguration(defaultDepth: 0)
        }
    }

    @Test("Invalid threadCount throws invalidConfiguration")
    func invalidThreadCountThrows() {
        #expect(throws: EngineError.self) {
            _ = try EngineConfiguration(threadCount: 0)
        }
    }

    @Test("Invalid hashSizeMB throws invalidConfiguration")
    func invalidHashSizeThrows() {
        #expect(throws: EngineError.self) {
            _ = try EngineConfiguration(hashSizeMB: 5000)
        }
    }

    @Test("Engine stores configuration at init")
    func engineStoresConfiguration() async throws {
        let config = try EngineConfiguration(defaultDepth: 12)
        let engine = LucidEngine(configuration: config)
        let stored = await engine.configuration
        #expect(stored == config)
    }

    @Test("Engine uses default configuration when none provided")
    func engineUsesDefaultConfig() async {
        let engine = LucidEngine()
        let stored = await engine.configuration
        #expect(stored == .default)
    }

    // MARK: - Initial State

    @Test("Engine is not running after init")
    func engineNotRunningAfterInit() async {
        let engine = LucidEngine()
        let running = await engine.isRunning
        #expect(running == false)
    }

    // MARK: - Start

    @Test("Engine is running after start")
    func engineRunningAfterStart() async throws {
        let engine = LucidEngine()
        try await engine.start()
        let running = await engine.isRunning
        #expect(running == true)
        await engine.shutdown()
    }

    @Test("Double start is idempotent")
    func doubleStartIsIdempotent() async throws {
        let engine = LucidEngine()
        try await engine.start()
        try await engine.start()
        let running = await engine.isRunning
        #expect(running == true)
        await engine.shutdown()
    }

    // MARK: - Shutdown

    @Test("Engine is not running after shutdown")
    func engineNotRunningAfterShutdown() async throws {
        let engine = LucidEngine()
        try await engine.start()
        await engine.shutdown()
        let running = await engine.isRunning
        #expect(running == false)
    }

    @Test("Shutdown before start is safe")
    func shutdownBeforeStartIsSafe() async {
        let engine = LucidEngine()
        await engine.shutdown()
        let running = await engine.isRunning
        #expect(running == false)
    }

    @Test("Double shutdown is idempotent")
    func doubleShutdownIsIdempotent() async throws {
        let engine = LucidEngine()
        try await engine.start()
        await engine.shutdown()
        await engine.shutdown()
        let running = await engine.isRunning
        #expect(running == false)
    }

    // MARK: - Operations After Shutdown

    @Test("ensureRunning throws engineNotRunning when not started")
    func ensureRunningThrowsWhenNotStarted() async {
        let engine = LucidEngine()
        await #expect(throws: EngineError.engineNotRunning) {
            try await engine.ensureRunning()
        }
    }

    @Test("ensureRunning throws engineNotRunning after shutdown")
    func ensureRunningThrowsAfterShutdown() async throws {
        let engine = LucidEngine()
        try await engine.start()
        await engine.shutdown()
        await #expect(throws: EngineError.engineNotRunning) {
            try await engine.ensureRunning()
        }
    }

    @Test("ensureRunning succeeds when engine is running")
    func ensureRunningSucceedsWhenRunning() async throws {
        let engine = LucidEngine()
        try await engine.start()
        try await engine.ensureRunning()
        await engine.shutdown()
    }

    // MARK: - Restart Cycle

    @Test("Engine can be restarted after shutdown")
    func engineCanRestart() async throws {
        let engine = LucidEngine()
        try await engine.start()
        await engine.shutdown()
        try await engine.start()
        let running = await engine.isRunning
        #expect(running == true)
        await engine.shutdown()
    }
}
