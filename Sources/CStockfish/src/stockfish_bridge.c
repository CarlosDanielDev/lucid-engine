#include "stockfish_bridge.h"
#include <string.h>
#include <stdatomic.h>

// Placeholder stubs -- replaced with real Stockfish integration in Issue #3.

static _Atomic int g_initialized = 0;

SFStatus sf_init(void) {
    int expected = 0;
    if (!atomic_compare_exchange_strong(&g_initialized, &expected, 1)) {
        return SF_ERR_ALREADY_INIT;
    }
    return SF_OK;
}

void sf_cleanup(void) {
    atomic_store(&g_initialized, 0);
}

SFStatus sf_assess_position(const char* fen, int depth, SFAssessResult* out_result) {
    if (!atomic_load(&g_initialized)) {
        return SF_ERR_NOT_INITIALIZED;
    }
    if (!fen) {
        return SF_ERR_NULL_POINTER;
    }
    if (!out_result) {
        return SF_ERR_NULL_POINTER;
    }
    if (depth < 1 || depth > SF_MAX_DEPTH) {
        return SF_ERR_INVALID_DEPTH;
    }
    if (strlen(fen) > SF_MAX_FEN_LENGTH) {
        return SF_ERR_INVALID_FEN;
    }

    memset(out_result, 0, sizeof(SFAssessResult));
    out_result->depth = depth;

    return SF_OK;
}
