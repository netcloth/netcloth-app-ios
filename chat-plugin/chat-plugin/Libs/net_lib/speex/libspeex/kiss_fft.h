#ifndef KISS_FFT_H
#define KISS_FFT_H

#include <stdlib.h>
#include <math.h>
#include "arch.h"

#ifdef __cplusplus
extern "C" {
#endif


#ifdef USE_SIMD
# include <xmmintrin.h>
# define kiss_fft_scalar __m128
#define KISS_FFT_MALLOC(nbytes) memalign(16,nbytes)
#else	
#define KISS_FFT_MALLOC speex_alloc
#endif	


#ifdef FIXED_POINT
#include "arch.h"	
#  define kiss_fft_scalar spx_int16_t
#else
# ifndef kiss_fft_scalar

#   define kiss_fft_scalar float
# endif
#endif

typedef struct {
    kiss_fft_scalar r;
    kiss_fft_scalar i;
}kiss_fft_cpx;

typedef struct kiss_fft_state* kiss_fft_cfg;


kiss_fft_cfg kiss_fft_alloc(int nfft,int inverse_fft,void * mem,size_t * lenmem); 

void kiss_fft(kiss_fft_cfg cfg,const kiss_fft_cpx *fin,kiss_fft_cpx *fout);

void kiss_fft_stride(kiss_fft_cfg cfg,const kiss_fft_cpx *fin,kiss_fft_cpx *fout,int fin_stride);

#define kiss_fft_free speex_free

void kiss_fft_cleanup(void);
	

#ifdef __cplusplus
} 
#endif

#endif
