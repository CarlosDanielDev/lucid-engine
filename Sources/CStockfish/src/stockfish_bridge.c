#include "stockfish_bridge.h"

// Placeholder stubs -- replaced with real Stockfish integration in Issue #3.

int sf_init(void) {
    return 0;
}

void sf_cleanup(void) {
}

int sf_assess_position(const char* fen, int depth) {
    return 0;
}

int sf_best_move(const char* fen, int depth, char* out_move, int buf_size) {
    return -1; // Not implemented
}
