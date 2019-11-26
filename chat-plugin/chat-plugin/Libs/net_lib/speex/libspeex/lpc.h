

#ifndef LPC_H
#define LPC_H

#include "arch.h"

void _spx_autocorr(
              const spx_word16_t * x,   
              spx_word16_t *ac,   
              int lag, int   n);

spx_word32_t                      
_spx_lpc(
    spx_coef_t       * lpc, 
    const spx_word16_t * ac,  
    int p
    );


#endif
