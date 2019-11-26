
#ifndef FFTWRAP_H
#define FFTWRAP_H

#include "arch.h"


void *spx_fft_init(int size);


void spx_fft_destroy(void *table);


void spx_fft(void *table, spx_word16_t *in, spx_word16_t *out);


void spx_ifft(void *table, spx_word16_t *in, spx_word16_t *out);


void spx_fft_float(void *table, float *in, float *out);


void spx_ifft_float(void *table, float *in, float *out);

#endif
