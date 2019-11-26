

#ifndef LTP_H
#define LTP_H

#include "speex/speex_bits.h"
#include "arch.h"


typedef struct {
   const signed char *gain_cdbk;
   int     gain_bits;
   int     pitch_bits;
} ltp_params;

#ifdef FIXED_POINT
#define gain_3tap_to_1tap(g) (ABS(g[1]) + (g[0]>0 ? g[0] : -SHR16(g[0],1)) + (g[2]>0 ? g[2] : -SHR16(g[2],1)))
#else
#define gain_3tap_to_1tap(g) (ABS(g[1]) + (g[0]>0 ? g[0] : -.5*g[0]) + (g[2]>0 ? g[2] : -.5*g[2]))
#endif

spx_word32_t inner_prod(const spx_word16_t *x, const spx_word16_t *y, int len);

void open_loop_nbest_pitch(spx_word16_t *sw, int start, int end, int len, int *pitch, spx_word16_t *gain, int N, char *stack);



int pitch_search_3tap(
spx_word16_t target[],                 
spx_word16_t *sw,
spx_coef_t ak[],                     
spx_coef_t awk1[],                   
spx_coef_t awk2[],                   
spx_sig_t exc[],                    
const void *par,
int   start,                    
int   end,                      
spx_word16_t pitch_coef,               
int   p,                        
int   nsf,                      
SpeexBits *bits,
char *stack,
spx_word16_t *exc2,
spx_word16_t *r,
int   complexity,
int   cdbk_offset,
int plc_tuning,
spx_word32_t *cumul_gain
);


void pitch_unquant_3tap(
spx_word16_t exc[],             
spx_word32_t exc_out[],         
int   start,                    
int   end,                      
spx_word16_t pitch_coef,        
const void *par,
int   nsf,                      
int *pitch_val,
spx_word16_t *gain_val,
SpeexBits *bits,
char *stack,
int lost,
int subframe_offset,
spx_word16_t last_pitch_gain,
int cdbk_offset
);


int forced_pitch_quant(
spx_word16_t target[],                 
spx_word16_t *sw,
spx_coef_t ak[],                     
spx_coef_t awk1[],                   
spx_coef_t awk2[],                   
spx_sig_t exc[],                    
const void *par,
int   start,                    
int   end,                      
spx_word16_t pitch_coef,               
int   p,                        
int   nsf,                      
SpeexBits *bits,
char *stack,
spx_word16_t *exc2,
spx_word16_t *r,
int complexity,
int cdbk_offset,
int plc_tuning,
spx_word32_t *cumul_gain
);


void forced_pitch_unquant(
spx_word16_t exc[],             
spx_word32_t exc_out[],         
int   start,                    
int   end,                      
spx_word16_t pitch_coef,        
const void *par,
int   nsf,                      
int *pitch_val,
spx_word16_t *gain_val,
SpeexBits *bits,
char *stack,
int lost,
int subframe_offset,
spx_word16_t last_pitch_gain,
int cdbk_offset
);

#endif 
