#ifndef STOCKFISH_BRIDGE_H
#define STOCKFISH_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Max buffer size for a single UCI move string (e.g. "e2e4\0", "e7e8q\0").
#define SF_MOVE_BUF_SIZE 8

/// Maximum number of moves stored in a principal variation line.
#define SF_MAX_PV_LENGTH 32

/// Maximum valid FEN string length (standard FEN is ~90 chars).
#define SF_MAX_FEN_LENGTH 256

/// Maximum search depth.
#define SF_MAX_DEPTH 100

// ---------------------------------------------------------------------------
// Return Codes
// ---------------------------------------------------------------------------

/// Status codes returned by all sf_ functions.
typedef enum {
    SF_OK                   =  0,
    SF_ERR_NOT_INITIALIZED  = -1,
    SF_ERR_INVALID_FEN      = -2,
    SF_ERR_INVALID_DEPTH    = -3,
    SF_ERR_NULL_POINTER     = -4,
    SF_ERR_SEARCH_FAILED    = -5,
    SF_ERR_ALREADY_INIT     = -6
} SFStatus;

// ---------------------------------------------------------------------------
// Score Type
// ---------------------------------------------------------------------------

/// Discriminator for score interpretation.
typedef enum {
    SF_SCORE_CENTIPAWNS = 0,  ///< score field is centipawns from side-to-move POV
    SF_SCORE_MATE       = 1   ///< score field is moves-to-mate (positive = winning)
} SFScoreType;

// ---------------------------------------------------------------------------
// Assessment Result
// ---------------------------------------------------------------------------

/// Result populated by sf_assess_position.
/// All fields are only valid when the function returns SF_OK.
typedef struct {
    SFScoreType score_type;
    int         score;
    char        best_move[SF_MOVE_BUF_SIZE];
    char        pv[SF_MAX_PV_LENGTH][SF_MOVE_BUF_SIZE];
    int         pv_length;
    int         depth;
    long        nodes;
} SFAssessResult;

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

/// Initialize Stockfish engine. Must be called before any assessment.
/// Returns SF_OK on success, SF_ERR_ALREADY_INIT if called twice.
SFStatus sf_init(void);

/// Release all Stockfish resources. Safe to call if not initialized (no-op).
void sf_cleanup(void);

// ---------------------------------------------------------------------------
// Assessment
// ---------------------------------------------------------------------------

/// Assess a position given a FEN string and search depth.
///
/// @param fen        Null-terminated FEN string.
/// @param depth      Search depth (must be >= 1).
/// @param out_result Pointer to caller-allocated SFAssessResult. Populated on SF_OK.
/// @return SF_OK on success, or a negative SFStatus error code.
///
/// The score is always from the side-to-move's perspective.
/// This function MUST NOT write to stdout, stderr, or use dup2/freopen.
SFStatus sf_assess_position(const char* fen, int depth, SFAssessResult* out_result);

#ifdef __cplusplus
}
#endif

#endif /* STOCKFISH_BRIDGE_H */
