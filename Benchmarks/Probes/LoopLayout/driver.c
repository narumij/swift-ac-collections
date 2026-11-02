/*
 * Reduced probe for OPS-215: run identical copies of the 222-byte measured closure
 * (NextPermutations sequential batched, extracted from CI artifacts) at different
 * code placements and with different input-buffer placements.
 *
 * This is a REDUCED probe. It reproduces only the machine code of the inner measured
 * closure; it does not reproduce the Swift benchmark harness (Timer, outer closure,
 * GateKeeper object lifetime, blackHole, validation).
 *
 * Calling-convention assumption (checked against the extracted bytes):
 *   The closure is a Swift-convention function, but it only uses the first six integer
 *   argument registers, which swiftcc assigns exactly like System V:
 *     rdi = reps (Int)            rsi = elements (UnsafePointer<Int>)
 *     rdx = count (Int)           rcx = GateKeeper object pointer
 *     r8  = generation (UInt)     r9  = &sum (inout Int, result store)
 *   It does not read r12/r13/r14 (swift self/error/async context), uses no stack slots
 *   besides the saved rbp, and clobbers only rax, rcx, r8, r10, r11, xmm0-xmm2 (all
 *   caller-saved in System V). It traps (ud2) if reps < 0, count < 0, or
 *   *(uintptr_t *)(gate + 16) != generation. reps == 0 stores 0.
 *   Hence it can be called from C through a System V function pointer.
 */
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <inttypes.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "closure_bytes.h"

/* Three machine words; the closure compares word [2] (offset 16) with `generation`. */
struct gate {
    uintptr_t word0;
    uintptr_t word1;
    uintptr_t generation;
};
_Static_assert(sizeof(uintptr_t) == 8, "x86_64 only");
_Static_assert(offsetof(struct gate, generation) == 16, "gate layout");
_Static_assert(sizeof(intptr_t) == 8 && sizeof(int64_t) == 8, "word size");

typedef void (*closure_fn)(intptr_t reps, const int64_t *elements, intptr_t count,
                           const struct gate *gate, uintptr_t generation, int64_t *result);

/* Defined in probe_copies.S */
extern void probe_copy_0(void), probe_copy_1(void), probe_copy_2(void), probe_copy_3(void),
    probe_copy_4(void), probe_copy_5(void), probe_copy_6(void), probe_copy_7(void),
    probe_copy_8(void), probe_copy_9(void);
extern const int64_t probe_copy_pads[];
extern const int64_t probe_copy_count;
static void (*const copies[])(void) = {
    probe_copy_0, probe_copy_1, probe_copy_2, probe_copy_3, probe_copy_4,
    probe_copy_5, probe_copy_6, probe_copy_7, probe_copy_8, probe_copy_9,
};
#define NCOPIES ((int)(sizeof(copies) / sizeof(copies[0])))

/* Input-buffer placements: offset (bytes) from a 4096-aligned allocation.
 * Two separate buffers with offset 0 serve as the same-placement data control. */
static const size_t data_offsets[] = {0, 0, 8, 16, 24, 32, 48, 64, 2048};
#define NBUFFERS ((int)(sizeof(data_offsets) / sizeof(data_offsets[0])))

/* Code copies used for the data sweep: first pad-32 copy and first pad-48 copy. */
enum { DATA_SWEEP_PAD_A = 32, DATA_SWEEP_PAD_B = 48 };

struct task {
    const char *experiment; /* "code" or "data" */
    int copy;
    int buffer;
    int size_index;
};

static uint64_t rng_state;
static uint64_t rng_next(void) { /* xorshift64* */
    rng_state ^= rng_state >> 12;
    rng_state ^= rng_state << 25;
    rng_state ^= rng_state >> 27;
    return rng_state * 2685821657736338717ULL;
}

static uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static void usage(const char *argv0) {
    fprintf(stderr,
            "usage: %s [--seed N] [--rounds N] [--warmup N] [--max-seconds N]\n"
            "          [--elements-per-sample N] [--sizes a,b,c] [--checksum-only]\n"
            "  CSV goes to stdout, metadata lines (prefixed '#') to stderr.\n",
            argv0);
}

/* Parse a decimal integer in [lo, hi]; reject trailing garbage and out-of-range values. */
static int parse_range(const char *name, const char *text, long long lo, long long hi, long long *out) {
    char *end = NULL;
    errno = 0;
    long long v = strtoll(text, &end, 10);
    if (errno || end == text || *end != '\0' || v < lo || v > hi) {
        fprintf(stderr, "invalid %s '%s' (allowed %lld..%lld)\n", name, text, lo, hi);
        return 0;
    }
    *out = v;
    return 1;
}

/* Limits keep a mistaken invocation from running for hours or allocating huge buffers. */
#define MAX_SIZES 8
#define MAX_SIZE (1LL << 20)              /* elements per buffer (8 MiB) */
#define MAX_ELEMENTS_PER_SAMPLE (1LL << 30)
#define MAX_ROUNDS 1000
#define MAX_WARMUP 100
#define MAX_SECONDS_LIMIT 3600

int main(int argc, char **argv) {
    uint64_t seed = 20261102;
    int rounds = 21, warmup = 2, max_seconds = 300, checksum_only = 0;
    long long elements_per_sample = 1LL << 24;
    long long sizes[MAX_SIZES] = {64, 256, 1024};
    int nsizes = 3;

    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        const char *v = (i + 1 < argc) ? argv[i + 1] : NULL;
        long long x;
        if (!strcmp(a, "--checksum-only")) { checksum_only = 1; continue; }
        if (!v) { usage(argv[0]); return 2; }
        i++;
        if (!strcmp(a, "--seed")) {
            if (!parse_range("--seed", v, 0, LLONG_MAX, &x)) return 2;
            seed = (uint64_t)x;
        } else if (!strcmp(a, "--rounds")) {
            if (!parse_range("--rounds", v, 1, MAX_ROUNDS, &x)) return 2;
            rounds = (int)x;
        } else if (!strcmp(a, "--warmup")) {
            if (!parse_range("--warmup", v, 0, MAX_WARMUP, &x)) return 2;
            warmup = (int)x;
        } else if (!strcmp(a, "--max-seconds")) {
            if (!parse_range("--max-seconds", v, 1, MAX_SECONDS_LIMIT, &x)) return 2;
            max_seconds = (int)x;
        } else if (!strcmp(a, "--elements-per-sample")) {
            if (!parse_range("--elements-per-sample", v, 1, MAX_ELEMENTS_PER_SAMPLE, &x)) return 2;
            elements_per_sample = x;
        } else if (!strcmp(a, "--sizes")) {
            nsizes = 0;
            char *list = strdup(v);
            if (!list) { perror("strdup"); return 2; }
            int ok = 1;
            for (char *t = strtok(list, ","); t; t = strtok(NULL, ",")) {
                if (nsizes == MAX_SIZES) {
                    fprintf(stderr, "too many sizes (max %d)\n", MAX_SIZES);
                    ok = 0;
                    break;
                }
                if (!parse_range("size", t, 1, MAX_SIZE, &x)) { ok = 0; break; }
                sizes[nsizes++] = x;
            }
            free(list);
            if (!ok) return 2;
            if (nsizes == 0) { fprintf(stderr, "--sizes needs at least one size\n"); return 2; }
        } else {
            usage(argv[0]);
            return 2;
        }
    }
    if (seed == 0) seed = 1;
    if (checksum_only) { rounds = 1; warmup = 0; elements_per_sample = 1 << 12; }

    /* --- verify code copies: identical bytes and intended placement --- */
    if (probe_copy_count != NCOPIES) {
        fprintf(stderr, "copy table mismatch\n");
        return 1;
    }
    for (int c = 0; c < NCOPIES; c++) {
        const unsigned char *entry = (const unsigned char *)(uintptr_t)copies[c];
        uintptr_t loop = (uintptr_t)entry + CLOSURE_LOOP_OFFSET;
#if defined(PROBE_HOST_TEST)
        /* Optional host test: link C stand-ins instead of probe_copies.S (harness logic only). */
        (void)closure_reference;
        fprintf(stderr, "# HOST TEST: copy %d is a C stand-in, placement/bytes not checked\n", c);
        continue;
#endif
        if (memcmp(entry, closure_reference, CLOSURE_LENGTH) != 0) {
            fprintf(stderr, "copy %d bytes differ from reference\n", c);
            return 1;
        }
        if ((int64_t)(loop % 64) != probe_copy_pads[c] || (int64_t)((uintptr_t)entry % 4096) != probe_copy_pads[c]) {
            fprintf(stderr, "copy %d placement unexpected: entry %p loop mod64 %u\n", c,
                    (const void *)entry, (unsigned)(loop % 64));
            return 1;
        }
        fprintf(stderr, "# copy %d pad %" PRId64 " entry %p loop %p loop_mod32 %u loop_mod64 %u bytes_ok 1\n",
                c, probe_copy_pads[c], (const void *)entry, (const void *)loop,
                (unsigned)(loop % 32), (unsigned)(loop % 64));
    }

    /* --- input buffers --- */
    long long max_size = 0;
    for (int s = 0; s < nsizes; s++) if (sizes[s] > max_size) max_size = sizes[s];
    int64_t *buffers[NBUFFERS];
    void *allocations[NBUFFERS];
    for (int b = 0; b < NBUFFERS; b++) {
        size_t bytes = (size_t)max_size * 8 + data_offsets[b];
        bytes = (bytes + 4095) & ~(size_t)4095;
        allocations[b] = aligned_alloc(4096, bytes);
        if (!allocations[b]) { perror("aligned_alloc"); return 1; }
        buffers[b] = (int64_t *)((char *)allocations[b] + data_offsets[b]);
        for (long long i = 0; i < max_size; i++) buffers[b][i] = i;
        fprintf(stderr, "# buffer %d offset %zu addr %p mod64 %u mod4096 %u\n", b, data_offsets[b],
                (void *)buffers[b], (unsigned)((uintptr_t)buffers[b] % 64),
                (unsigned)((uintptr_t)buffers[b] % 4096));
    }

    struct gate gate = {0, 0, 0x5eed};
    long long reps[8];
    for (int s = 0; s < nsizes; s++) {
        reps[s] = elements_per_sample / sizes[s];
        if (reps[s] < 1) reps[s] = 1;
        fprintf(stderr, "# size %lld reps %lld (fixed for all placements)\n", sizes[s], reps[s]);
    }

    /* --- task list: code sweep (fixed buffer 0) + data sweep (two fixed code copies) --- */
    int copy_a = -1, copy_b = -1;
    for (int c = 0; c < NCOPIES; c++) {
        if (copy_a < 0 && probe_copy_pads[c] == DATA_SWEEP_PAD_A) copy_a = c;
        if (copy_b < 0 && probe_copy_pads[c] == DATA_SWEEP_PAD_B) copy_b = c;
    }
    int ntasks = nsizes * (NCOPIES + 2 * NBUFFERS);
    struct task *tasks = calloc((size_t)ntasks, sizeof *tasks);
    int t = 0;
    for (int s = 0; s < nsizes; s++) {
        for (int c = 0; c < NCOPIES; c++) tasks[t++] = (struct task){"code", c, 0, s};
        for (int b = 0; b < NBUFFERS; b++) {
            tasks[t++] = (struct task){"data", copy_a, b, s};
            tasks[t++] = (struct task){"data", copy_b, b, s};
        }
    }

    rng_state = seed;
    fprintf(stderr, "# seed %" PRIu64 " rounds %d warmup %d max_seconds %d elements_per_sample %lld tasks_per_round %d\n",
            seed, rounds, warmup, max_seconds, elements_per_sample, ntasks);
    printf("round,warmup,position,experiment,copy,pad,loop_addr,loop_mod32,loop_mod64,"
           "buffer,data_off,data_addr,data_mod64,size,reps,ns,ok\n");

    uint64_t start = now_ns();
    int failures = 0, completed_rounds = 0, timed_out = 0;
    const uint64_t limit_ns = (uint64_t)max_seconds * 1000000000ULL;
    for (int r = 0; r < warmup + rounds && !timed_out; r++) {
        for (int i = ntasks - 1; i > 0; i--) { /* Fisher-Yates with fixed seed */
            int j = (int)(rng_next() % (uint64_t)(i + 1));
            struct task tmp = tasks[i]; tasks[i] = tasks[j]; tasks[j] = tmp;
        }
        for (int p = 0; p < ntasks; p++) {
            const struct task *k = &tasks[p];
            closure_fn fn = (closure_fn)(uintptr_t)copies[k->copy];
            long long n = sizes[k->size_index], rp = reps[k->size_index];
            int64_t result = -1;
            uint64_t t0 = now_ns();
            fn((intptr_t)rp, buffers[k->buffer], (intptr_t)n, &gate, gate.generation, &result);
            uint64_t t1 = now_ns();
            /* wrapping arithmetic, as in the Swift code (&+=) */
            uint64_t expected = (uint64_t)rp * ((uint64_t)n * (uint64_t)(n - 1) / 2);
            int ok = (uint64_t)result == expected;
            if (!ok) failures++;
            uintptr_t loop = (uintptr_t)copies[k->copy] + CLOSURE_LOOP_OFFSET;
            printf("%d,%d,%d,%s,%d,%" PRId64 ",0x%" PRIxPTR ",%u,%u,%d,%zu,0x%" PRIxPTR ",%u,%lld,%lld,%" PRIu64 ",%d\n",
                   r, r < warmup, p, k->experiment, k->copy, probe_copy_pads[k->copy], loop,
                   (unsigned)(loop % 32), (unsigned)(loop % 64), k->buffer, data_offsets[k->buffer],
                   (uintptr_t)buffers[k->buffer], (unsigned)((uintptr_t)buffers[k->buffer] % 64),
                   n, rp, t1 - t0, ok);
            /* checked per task so a mistaken invocation cannot run far past the limit */
            if (t1 - start >= limit_ns && !(r == warmup + rounds - 1 && p == ntasks - 1)) {
                timed_out = 1;
                fprintf(stderr, "# stopped by --max-seconds in round %d at task %d\n", r, p);
                break;
            }
        }
        if (!timed_out) completed_rounds = r + 1;
    }
    fprintf(stderr, "# completed_rounds %d (incl. warmup) failures %d elapsed_ms %" PRIu64 "\n",
            completed_rounds, failures, (now_ns() - start) / 1000000ULL);
    for (int b = 0; b < NBUFFERS; b++) free(allocations[b]);
    free(tasks);
    if (failures) return 1;
    if (timed_out || completed_rounds < warmup + rounds) return 3; /* incomplete: not a result */
    return 0;
}
