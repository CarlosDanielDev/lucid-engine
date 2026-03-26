import Testing
@testable import LucidEngine

// Smoke test: Package.swift compiles, LucidEngine is importable,
// and C bridge symbols are reachable through the actor.

@Suite("Package Structure", .serialized)
struct PackageStructureTests {

    @Test("LucidEngine module compiles and basic lifecycle works")
    func smokeTest() async throws {
        let engine = LucidEngine()
        #expect(await engine.isRunning == false)
        try await engine.start()
        #expect(await engine.isRunning == true)
        await engine.shutdown()
        #expect(await engine.isRunning == false)
    }
}
