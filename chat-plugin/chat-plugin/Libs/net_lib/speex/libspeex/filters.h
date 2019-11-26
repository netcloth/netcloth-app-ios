

#ifndef FILTERS_H
#define FILTERS_H

#include "arch.h"

spx_word16_t compute_rms(const spx_sig_t *x, int len);
spx_word16_t compute_rms16(const spx_word16_t *x, int len);
void signal_mul(const spx_sig_t *x, spx_sig_t *y, spx_word32_t scale, int len);
void signal_div(const spx_word16_t *x, spx_word16_t *y, spx_word32_t scale, int len);

#ifdef FIXED_POINT

int normalize16(const spx_sig_t *x, spx_word16_t *y, spx_sig_t max_scale, int len);

#endif


#define HIGHPASS_NARROWBAND 0
#define HIGHPASS_WIDEBAND 2
#define HIGHPASS_INPUT 0
#define HIGHPASS_OUTPUT 1
#define HIGHPASS_IRS 4

void highpass(const spx_word16_t *x, spx_word16_t *y, int len, int filtID, spx_mem_t *mem);


void qmf_decomp(const spx_word16_t *xx, const spx_word16_t *aa, spx_word16_t *, spx_word16_t *y2, int N, int M, spx_word16_t *mem, char *stack);
void qmf_synth(const spx_word16_t *x1, const spx_word16_t *x2, const spx_word16_t *a, spx_word16_t *y, int N, int M, spx_word16_t *mem1, spx_word16_t *mem2, char *stack);

void filter_mem16(const spx_word16_t *x, const spx_coef_t *num, const spx_coef_t *den, spx_word16_t *y, int N, int ord, spx_mem_t *mem, char *stack);

#ifdef MERGE_FILTERS

#define OVERRIDE_IIR_MEM16
#define OVERRIDE_FIR_MEM16
extern const spx_word16_t zeros[];
#define iir_mem16(x, den, y, N, ord, mem, stack) filter_mem16(x, zeros, den, y,  N, ord, mem, stack)
#define fir_mem16(x, num, y, N, ord, mem, stack) filter_mem16(x, num, zeros, y,  N, ord, mem, stack)

#else 
void iir_mem16(const spx_word16_t *x, const spx_coef_t *den, spx_word16_t *y, int N, int ord, spx_mem_t *mem, char *stack);
void fir_mem16(const spx_word16_t *x, const spx_coef_t *num, spx_word16_t *y, int N, int ord, spx_mem_t *mem, char *stack);
#endif  


void bw_lpc(spx_word16_t , const spx_coef_t *lpc_in, spx_coef_t *lpc_out, int order);
void sanitize_values32(spx_word32_t *vec, spx_word32_t min_val, spx_word32_t max_val, int len);


void syn_percep_zero16(const spx_word16_t *xx, const spx_coef_t *ak, const spx_coef_t *awk1, const spx_coef_t *awk2, spx_word16_t *y, int N, int ord, char *stack);
void residue_percep_zero16(const spx_word16_t *xx, const spx_coef_t *ak, const spx_coef_t *awk1, const spx_coef_t *awk2, spx_word16_t *y, int N, int ord, char *stack);

void compute_impulse_response(const spx_coef_t *ak, const spx_coef_t *awk1, const spx_coef_t *awk2, spx_word16_t *y, int N, int ord, char *stack);

void multicomb(
spx_word16_t *exc,          
spx_word16_t *new_exc,      
spx_coef_t *ak,           
int p,               
int nsf,             
int pitch,           
int max_pitch,   
spx_word16_t  comb_gain,    
char *stack
);


#define filter10(x, num, den, y, N, mem, stack) filter_mem16(x, num, den, y, N, 10, mem, stack)


#endif
