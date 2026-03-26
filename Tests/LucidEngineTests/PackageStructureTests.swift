import Testing
@testable import LucidEngine

// MARK: - Package Structure Smoke Tests
//
// Prove Issue #1 is complete:
// - Package.swift compiles with CStockfish + LucidEngine targets
// - LucidEngine module is importable
// - C bridge symbols are reachable through the actor
// - Basic lifecycle (start/shutdown) does not crash

@Suite("Package Structure")
struct PackageStructureTests {

    @Test("LucidEngine can be instantiated")
    func engineInstantiates() async {
        let engine = LucidEngine()
        let isInit = await engine.isInitialized
        #expect(isInit == false)
    }

    @Test("Engine starts without error")
    func engineStartSucceeds() async throws {
        let engine = LucidEngine()
        try await engine.start()
        let isInit = await engine.isInitialized
        #expect(isInit == true)
    }

    @Test("Engine start is idempotent")
    func engineStartIsIdempotent() async throws {
        let engine = LucidEngine()
        try await engine.start()
        try await engine.start()
        let isInit = await engine.isInitialized
        #expect(isInit == true)
    }

    @Test("Engine shuts down cleanly")
    func engineShutdownSucceeds() async throws {
        let engine = LucidEngine()
        try await engine.start()
        await engine.shutdown()
        let isInit = await engine.isInitialized
        #expect(isInit == false)
    }

    @Test("Engine shutdown before start does not crash")
    func shutdownBeforeStartIsNoop() async {
        let engine = LucidEngine()
        await engine.shutdown()
        let isInit = await engine.isInitialized
        #expect(isInit == false)
    }
}
