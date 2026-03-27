// stockfish_bridge.cpp — Real Stockfish integration for LucidEngine
//
// SAFETY: No stdout/stderr writes, no dup2, no freopen.
// Output suppressed via std::cout/cerr rdbuf redirect to NullStreambuf.
//
// LOCK ORDERING: g_engine_mutex > resultMutex (callback-local).

#include "stockfish_bridge.h"

#include "bitboard.h"
#include "engine.h"
#include "position.h"
#include "score.h"
#include "search.h"
#include "types.h"
#include "uci.h"

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstring>
#include <iostream>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>

using namespace Stockfish;

// ---------------------------------------------------------------------------
// Discarding streambuf — suppresses output without unbounded memory growth
// ---------------------------------------------------------------------------

class NullStreambuf : public std::streambuf {
protected:
    int_type overflow(int_type c) override {
        return traits_type::not_eof(c);
    }
    std::streamsize xsputn(const char*, std::streamsize n) override {
        return n;
    }
};

// ---------------------------------------------------------------------------
// Global state
// ---------------------------------------------------------------------------

// Every sf_init() increments, every sf_cleanup() decrements.
// Engine is created on first init, kept alive across cycles for fast re-init.
static std::atomic<int>  g_ref_count{0};
static std::atomic<bool> g_statics_initialized{false};
static std::mutex        g_engine_mutex;

static std::unique_ptr<Engine> g_engine;

// Output suppression using discarding streambuf (no memory growth)
static NullStreambuf   g_null_buf;
static std::streambuf* g_saved_cout_buf = nullptr;
static std::streambuf* g_saved_cerr_buf = nullptr;

// ---------------------------------------------------------------------------
// Output suppression (rdbuf redirect, NOT dup2/freopen)
// ---------------------------------------------------------------------------

static void suppress_output() {
    if (!g_saved_cout_buf) {
        g_saved_cout_buf = std::cout.rdbuf(&g_null_buf);
    }
    if (!g_saved_cerr_buf) {
        g_saved_cerr_buf = std::cerr.rdbuf(&g_null_buf);
    }
}

static void install_noop_callbacks() {
    g_engine->set_on_update_no_moves([](const Engine::InfoShort&) {});
    g_engine->set_on_update_full([](const Engine::InfoFull&) {});
    g_engine->set_on_iter([](const Engine::InfoIter&) {});
    g_engine->set_on_bestmove([](std::string_view, std::string_view) {});
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

extern "C" SFStatus sf_init(void) {
    std::lock_guard<std::mutex> lock(g_engine_mutex);

    int prev = g_ref_count.fetch_add(1);
    if (prev > 0) {
        // Engine already initialized — just add a reference.
        // Caller MUST pair with sf_cleanup().
        return SF_ERR_ALREADY_INIT;
    }

    // First init — create the engine if it doesn't exist
    if (g_engine) {
        // Engine still alive from a previous cycle, reuse it
        return SF_OK;
    }

    try {
        suppress_output();

        // Static subsystem init — safe to call only once
        bool statics_expected = false;
        if (g_statics_initialized.compare_exchange_strong(statics_expected, true)) {
            Bitboards::init();
            Position::init();
        }

        // Create the engine (loads NNUE networks)
        g_engine = std::make_unique<Engine>();

        // Configure for analysis: single thread, 64MB hash
        {
            std::istringstream threadsOpt("name Threads value 1");
            g_engine->get_options().setoption(threadsOpt);
            std::istringstream hashOpt("name Hash value 64");
            g_engine->get_options().setoption(hashOpt);
        }

        // Install no-op callbacks to prevent any output
        install_noop_callbacks();

        return SF_OK;
    } catch (...) {
        g_engine.reset();
        g_ref_count.store(0);
        return SF_ERR_NOT_INITIALIZED;
    }
}

extern "C" void sf_cleanup(void) {
    std::lock_guard<std::mutex> lock(g_engine_mutex);

    int prev = g_ref_count.load();
    if (prev <= 0) return;

    g_ref_count.fetch_sub(1);

    // Stop any running search regardless of ref count
    if (g_engine) {
        g_engine->stop();
        g_engine->wait_for_search_finished();
    }
    // Engine kept alive for fast re-init. Output suppression stays active.
}

// ---------------------------------------------------------------------------
// Assessment
// ---------------------------------------------------------------------------

// Internal timeout for the CV wait — prevents permanent deadlock if the
// bestmove callback never fires. 5 minutes is generous; the Swift-side
// timeout (default 5s) should always fire first.
static constexpr auto CV_WAIT_TIMEOUT = std::chrono::minutes(5);

extern "C" SFStatus sf_assess_position(const char* fen, int depth, SFAssessResult* out_result) {
    if (g_ref_count.load() <= 0) {
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
    if (std::strlen(fen) > SF_MAX_FEN_LENGTH) {
        return SF_ERR_INVALID_FEN;
    }

    std::memset(out_result, 0, sizeof(SFAssessResult));

    std::lock_guard<std::mutex> lock(g_engine_mutex);

    if (!g_engine) {
        return SF_ERR_NOT_INITIALIZED;
    }

    // Set the position — catch invalid FEN
    try {
        g_engine->set_position(std::string(fen), {});
    } catch (...) {
        return SF_ERR_INVALID_FEN;
    }

    // Captured data from callbacks
    int         capturedScoreCp   = 0;
    bool        capturedIsMate    = false;
    int         capturedMatePlies = 0;
    int         capturedDepth     = 0;
    size_t      capturedNodes     = 0;
    std::string capturedPV;
    std::string capturedBestMove;

    bool        searchDone = false;
    std::mutex  resultMutex;
    std::condition_variable resultCV;

    // Capture search info from the full update callback.
    // NOTE: These lambdas capture stack locals by reference. This is safe
    // because we ALWAYS wait for search completion before returning.
    // The wait_for_search_finished() + CV wait guarantee the callbacks
    // complete before this stack frame is destroyed.
    g_engine->set_on_update_full([&](const Engine::InfoFull& info) {
        if (info.depth < depth) return;
        std::lock_guard<std::mutex> lk(resultMutex);
        capturedDepth = info.depth;
        capturedNodes = info.nodes;
        capturedPV    = std::string(info.pv);

        // Extract score from the Score variant
        info.score.visit([&](auto&& val) {
            using T = std::decay_t<decltype(val)>;
            if constexpr (std::is_same_v<T, Score::Mate>) {
                capturedIsMate    = true;
                capturedMatePlies = val.plies;
            } else if constexpr (std::is_same_v<T, Score::InternalUnits>) {
                capturedIsMate  = false;
                capturedScoreCp = val.value;
            } else if constexpr (std::is_same_v<T, Score::Tablebase>) {
                capturedIsMate    = true;
                capturedMatePlies = val.win ? val.plies : -val.plies;
            }
        });
    });

    // Capture bestmove from the bestmove callback
    g_engine->set_on_bestmove([&](std::string_view bestmove, std::string_view) {
        std::lock_guard<std::mutex> lk(resultMutex);
        capturedBestMove = std::string(bestmove);
        searchDone = true;
        resultCV.notify_one();
    });

    // Configure search: depth only
    Search::LimitsType limits;
    limits.depth = depth;

    // Start the search (non-blocking)
    g_engine->go(limits);

    // Wait for search to complete
    g_engine->wait_for_search_finished();

    // Wait for the bestmove callback with a safety timeout to prevent
    // permanent deadlock if the callback never fires (e.g., engine bug).
    {
        std::unique_lock<std::mutex> lk(resultMutex);
        if (!resultCV.wait_for(lk, CV_WAIT_TIMEOUT, [&] { return searchDone; })) {
            // Timed out — reset callbacks and report failure
            install_noop_callbacks();
            return SF_ERR_SEARCH_FAILED;
        }
    }

    // Reset callbacks to no-ops
    install_noop_callbacks();

    // Populate result struct
    if (capturedIsMate) {
        out_result->score_type = SF_SCORE_MATE;
        // Convert plies to moves: positive = winning, negative = losing
        if (capturedMatePlies > 0) {
            out_result->score = (capturedMatePlies + 1) / 2;
        } else {
            out_result->score = -((-capturedMatePlies + 1) / 2);
        }
    } else {
        out_result->score_type = SF_SCORE_CENTIPAWNS;
        out_result->score = capturedScoreCp;
    }

    // Best move
    if (!capturedBestMove.empty()) {
        std::strncpy(out_result->best_move, capturedBestMove.c_str(), SF_MOVE_BUF_SIZE - 1);
        out_result->best_move[SF_MOVE_BUF_SIZE - 1] = '\0';
    }

    // Principal variation: space-separated UCI moves
    if (!capturedPV.empty()) {
        std::istringstream pvStream(capturedPV);
        std::string moveStr;
        int pvIdx = 0;
        while (pvStream >> moveStr && pvIdx < SF_MAX_PV_LENGTH) {
            std::strncpy(out_result->pv[pvIdx], moveStr.c_str(), SF_MOVE_BUF_SIZE - 1);
            out_result->pv[pvIdx][SF_MOVE_BUF_SIZE - 1] = '\0';
            pvIdx++;
        }
        out_result->pv_length = pvIdx;
    }

    out_result->depth = depth;
    out_result->nodes = static_cast<long>(capturedNodes);

    return SF_OK;
}

// ---------------------------------------------------------------------------
// Cancellation
// ---------------------------------------------------------------------------

extern "C" void sf_stop_search(void) {
    if (g_ref_count.load() <= 0) return;
    if (g_engine) {
        g_engine->stop();
    }
}
