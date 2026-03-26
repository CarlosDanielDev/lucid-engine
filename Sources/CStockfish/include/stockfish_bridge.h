#ifndef STOCKFISH_BRIDGE_H
#define STOCKFISH_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

/// Max buffer size for UCI move strings (e.g. "e2e4\0", "e7e8q\0").
#define SF_MOVE_BUF_SIZE 8

/// Returns 0 on success, non-zero on failure.
int sf_init(void);

void sf_cleanup(void);

/// Returns centipawn score from white's perspective.
int sf_assess_position(const char* fen, int depth);

/// Writes UCI move string to out_move. Use SF_MOVE_BUF_SIZE for buf_size.
/// Returns 0 on success, non-zero on failure.
int sf_best_move(const char* fen, int depth, char* out_move, int buf_size);

#ifdef __cplusplus
}
#endif

#endif /* STOCKFISH_BRIDGE_H */
