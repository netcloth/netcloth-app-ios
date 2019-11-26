

#ifndef VQ_H
#define VQ_H

#include "arch.h"

int scal_quant(spx_word16_t in, const spx_word16_t *boundary, int entries);
int scal_quant32(spx_word32_t in, const spx_word32_t *boundary, int entries);

#ifdef _USE_SSE
#include <xmmintrin.h>
void vq_nbest(spx_word16_t *in, const __m128 *codebook, int len, int entries, __m128 *E, int N, int *nbest, spx_word32_t *best_dist, char *stack);

void vq_nbest_sign(spx_word16_t *in, const __m128 *codebook, int len, int entries, __m128 *E, int N, int *nbest, spx_word32_t *best_dist, char *stack);
#else
void vq_nbest(spx_word16_t *in, const spx_word16_t *codebook, int len, int entries, spx_word32_t *E, int N, int *nbest, spx_word32_t *best_dist, char *stack);

void vq_nbest_sign(spx_word16_t *in, const spx_word16_t *codebook, int len, int entries, spx_word32_t *E, int N, int *nbest, spx_word32_t *best_dist, char *stack);
#endif

#endif
