import Testing
import CStockfish

@Suite("Bridging Header", .serialized)
struct BridgingHeaderTests {

    private static let startingFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    // MARK: - Constants

    @Test("SF_MOVE_BUF_SIZE is 8")
    func moveBufSizeConstant() {
        #expect(SF_MOVE_BUF_SIZE == 8)
    }

    @Test("SF_MAX_PV_LENGTH is 32")
    func maxPvLengthConstant() {
        #expect(SF_MAX_PV_LENGTH == 32)
    }

    @Test("SF_MAX_FEN_LENGTH is 256")
    func maxFenLengthConstant() {
        #expect(SF_MAX_FEN_LENGTH == 256)
    }

    @Test("SF_MAX_DEPTH is 100")
    func maxDepthConstant() {
        #expect(SF_MAX_DEPTH == 100)
    }

    // MARK: - SFStatus Enum Values

    @Test("SFStatus enum values are correct")
    func statusEnumValues() {
        #expect(SF_OK.rawValue == 0)
        #expect(SF_ERR_NOT_INITIALIZED.rawValue == -1)
        #expect(SF_ERR_INVALID_FEN.rawValue == -2)
        #expect(SF_ERR_INVALID_DEPTH.rawValue == -3)
        #expect(SF_ERR_NULL_POINTER.rawValue == -4)
        #expect(SF_ERR_SEARCH_FAILED.rawValue == -5)
        #expect(SF_ERR_ALREADY_INIT.rawValue == -6)
    }

    // MARK: - SFScoreType Enum Values

    @Test("SFScoreType enum values are correct")
    func scoreTypeEnumValues() {
        #expect(SF_SCORE_CENTIPAWNS.rawValue == 0)
        #expect(SF_SCORE_MATE.rawValue == 1)
    }

    // MARK: - SFAssessResult Struct Visibility

    @Test("SFAssessResult can be zero-initialized from Swift")
    func resultIsStackAllocatable() {
        var result = SFAssessResult()
        result.score = 42
        #expect(result.score == 42)
    }

    @Test("SFAssessResult score_type field round-trips")
    func resultScoreTypeRoundTrips() {
        var result = SFAssessResult()
        result.score_type = SF_SCORE_MATE
        #expect(result.score_type == SF_SCORE_MATE)
    }

    @Test("SFAssessResult pv_length field round-trips")
    func resultPvLengthRoundTrips() {
        var result = SFAssessResult()
        result.pv_length = 15
        #expect(result.pv_length == 15)
    }

    @Test("SFAssessResult depth field round-trips")
    func resultDepthRoundTrips() {
        var result = SFAssessResult()
        result.depth = 20
        #expect(result.depth == 20)
    }

    @Test("SFAssessResult nodes field round-trips")
    func resultNodesRoundTrips() {
        var result = SFAssessResult()
        result.nodes = 1_000_000
        #expect(result.nodes == 1_000_000)
    }

    // MARK: - Lifecycle

    @Test("sf_init returns SF_OK on first call")
    func initReturnsOK() {
        sf_cleanup()
        let status = sf_init()
        #expect(status == SF_OK)
        sf_cleanup()
    }

    @Test("sf_init returns SF_ERR_ALREADY_INIT on second call")
    func doubleInitReturnsError() {
        sf_cleanup()
        _ = sf_init()
        let status = sf_init()
        #expect(status == SF_ERR_ALREADY_INIT)
        sf_cleanup()
    }

    @Test("sf_cleanup is safe to call when not initialized")
    func cleanupWhenNotInitialized() {
        sf_cleanup()
        sf_cleanup()
    }

    // MARK: - Assessment Preconditions

    @Test("sf_assess_position returns SF_ERR_NOT_INITIALIZED when engine not started")
    func assessWithoutInit() {
        sf_cleanup()
        var result = SFAssessResult()
        let status = sf_assess_position(Self.startingFEN, 10, &result)
        #expect(status == SF_ERR_NOT_INITIALIZED)
    }

    @Test("sf_assess_position returns SF_ERR_NULL_POINTER for nil FEN")
    func assessNullFEN() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let status = sf_assess_position(nil, 10, &result)
        #expect(status == SF_ERR_NULL_POINTER)
        sf_cleanup()
    }

    @Test("sf_assess_position returns SF_ERR_NULL_POINTER for nil result pointer")
    func assessNullResult() {
        sf_cleanup()
        _ = sf_init()
        let nilResult: UnsafeMutablePointer<SFAssessResult>? = nil
        let status = sf_assess_position(Self.startingFEN, 10, nilResult)
        #expect(status == SF_ERR_NULL_POINTER)
        sf_cleanup()
    }

    @Test("sf_assess_position returns SF_ERR_INVALID_DEPTH for depth 0")
    func assessDepthZero() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let status = sf_assess_position(Self.startingFEN, 0, &result)
        #expect(status == SF_ERR_INVALID_DEPTH)
        sf_cleanup()
    }

    @Test("sf_assess_position returns SF_ERR_INVALID_DEPTH for negative depth")
    func assessNegativeDepth() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let status = sf_assess_position(Self.startingFEN, -5, &result)
        #expect(status == SF_ERR_INVALID_DEPTH)
        sf_cleanup()
    }

    @Test("sf_assess_position returns SF_ERR_INVALID_DEPTH for depth exceeding SF_MAX_DEPTH")
    func assessExceedsMaxDepth() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let status = sf_assess_position(Self.startingFEN, Int32(SF_MAX_DEPTH) + 1, &result)
        #expect(status == SF_ERR_INVALID_DEPTH)
        sf_cleanup()
    }

    @Test("sf_assess_position returns SF_ERR_INVALID_FEN for oversized FEN string")
    func assessOversizedFEN() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let longFEN = String(repeating: "x", count: Int(SF_MAX_FEN_LENGTH) + 1)
        let status = sf_assess_position(longFEN, 10, &result)
        #expect(status == SF_ERR_INVALID_FEN)
        sf_cleanup()
    }

    // MARK: - Successful Assessment (Stub)

    @Test("sf_assess_position returns SF_OK with valid inputs")
    func assessReturnsOK() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        let status = sf_assess_position(Self.startingFEN, 10, &result)
        #expect(status == SF_OK)
        sf_cleanup()
    }

    @Test("Stub returns centipawn score type")
    func stubReturnsCentipawns() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        _ = sf_assess_position(Self.startingFEN, 10, &result)
        #expect(result.score_type == SF_SCORE_CENTIPAWNS)
        sf_cleanup()
    }

    @Test("Stub returns requested depth")
    func stubReturnsRequestedDepth() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        _ = sf_assess_position(Self.startingFEN, 18, &result)
        #expect(result.depth == 18)
        sf_cleanup()
    }

    @Test("Stub writes zero score and empty PV")
    func stubWritesZeroFields() {
        sf_cleanup()
        _ = sf_init()
        var result = SFAssessResult()
        _ = sf_assess_position(Self.startingFEN, 1, &result)
        #expect(result.score == 0)
        #expect(result.pv_length == 0)
        #expect(result.nodes == 0)
        #expect(result.best_move.0 == 0)
        sf_cleanup()
    }
}
