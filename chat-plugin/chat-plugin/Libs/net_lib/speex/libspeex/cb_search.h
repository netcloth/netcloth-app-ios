

#ifndef CB_SEARCH_H
#define CB_SEARCH_H

#include "speex/speex_bits.h"
#include "arch.h"


typedef struct split_cb_params {
   int     subvect_size;
   int     nb_subvect;
   const signed char  *shape_cb;
   int     shape_bits;
   int     have_sign;
} split_cb_params;


void split_cb_search_shape_sign(
spx_word16_t target[],             
spx_coef_t ak[],                
spx_coef_t awk1[],              
spx_coef_t awk2[],              
const void *par,                
int   p,                        
int   nsf,                      
spx_sig_t *exc,
spx_word16_t *r,
SpeexBits *bits,
char *stack,
int   complexity,
int   update_target
);

void split_cb_shape_sign_unquant(
spx_sig_t *exc,
const void *par,                
int   nsf,                      
SpeexBits *bits,
char *stack,
spx_int32_t *seed
);


void noise_codebook_quant(
spx_word16_t target[],             
spx_coef_t ak[],                
spx_coef_t awk1[],              
spx_coef_t awk2[],              
const void *par,                
int   p,                        
int   nsf,                      
spx_sig_t *exc,
spx_word16_t *r,
SpeexBits *bits,
char *stack,
int   complexity,
int   update_target
);


void noise_codebook_unquant(
spx_sig_t *exc,
const void *par,                
int   nsf,                      
SpeexBits *bits,
char *stack,
spx_int32_t *seed
);

#endif
