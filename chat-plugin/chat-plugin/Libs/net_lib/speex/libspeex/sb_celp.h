

#ifndef SB_CELP_H
#define SB_CELP_H

#include "modes.h"
#include "nb_celp.h"


typedef struct SBEncState {
   const SpeexMode *mode;         
   void *st_low;                  
   int    full_frame_size;        
   int    frame_size;             
   int    subframeSize;           
   int    nbSubframes;            
   int    windowSize;             
   int    lpcSize;                
   int    first;                  
   spx_word16_t  lpc_floor;       
   spx_word16_t  gamma1;          
   spx_word16_t  gamma2;          

   char  *stack;                  
   spx_word16_t *high;               
   spx_word16_t *h0_mem;

   const spx_word16_t *window;    
   const spx_word16_t *lagWindow;       
   spx_lsp_t *old_lsp;            
   spx_lsp_t *old_qlsp;           
   spx_coef_t *interp_qlpc;       

   spx_mem_t *mem_sp;             
   spx_mem_t *mem_sp2;
   spx_mem_t *mem_sw;             
   spx_word32_t *pi_gain;
   spx_word16_t *exc_rms;
   spx_word16_t *innov_rms_save;         

#ifndef DISABLE_VBR
   float  vbr_quality;            
   int    vbr_enabled;            
   spx_int32_t vbr_max;           
   spx_int32_t vbr_max_high;      
   spx_int32_t abr_enabled;       
   float  abr_drift;
   float  abr_drift2;
   float  abr_count;
   int    vad_enabled;            
   float  relative_quality;
#endif 
   
   int    encode_submode;
   const SpeexSubmode * const *submodes;
   int    submodeID;
   int    submodeSelect;
   int    complexity;
   spx_int32_t sampling_rate;

} SBEncState;



typedef struct SBDecState {
   const SpeexMode *mode;            
   void *st_low;               
   int    full_frame_size;
   int    frame_size;
   int    subframeSize;
   int    nbSubframes;
   int    lpcSize;
   int    first;
   spx_int32_t sampling_rate;
   int    lpc_enh_enabled;

   char  *stack;
   spx_word16_t *g0_mem, *g1_mem;

   spx_word16_t *excBuf;
   spx_lsp_t *old_qlsp;
   spx_coef_t *interp_qlpc;

   spx_mem_t *mem_sp;
   spx_word32_t *pi_gain;
   spx_word16_t *exc_rms;
   spx_word16_t *innov_save;      
   
   spx_word16_t last_ener;
   spx_int32_t seed;

   int    encode_submode;
   const SpeexSubmode * const *submodes;
   int    submodeID;
} SBDecState;



void *sb_encoder_init(const SpeexMode *m);


void sb_encoder_destroy(void *state);


int sb_encode(void *state, void *in, SpeexBits *bits);



void *sb_decoder_init(const SpeexMode *m);


void sb_decoder_destroy(void *state);


int sb_decode(void *state, SpeexBits *bits, void *out);

int sb_encoder_ctl(void *state, int request, void *ptr);

int sb_decoder_ctl(void *state, int request, void *ptr);

#endif
