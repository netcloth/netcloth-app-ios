

#ifndef NB_CELP_H
#define NB_CELP_H

#include "modes.h"
#include "speex/speex_callbacks.h"
#include "vbr.h"
#include "filters.h"

#ifdef VORBIS_PSYCHO
#include "vorbis_psy.h"
#endif

#define NB_ORDER 10
#define NB_FRAME_SIZE 160
#define NB_SUBFRAME_SIZE 40
#define NB_NB_SUBFRAMES 4
#define NB_PITCH_START 17
#define NB_PITCH_END 144

#define NB_WINDOW_SIZE (NB_FRAME_SIZE+NB_SUBFRAME_SIZE)
#define NB_EXCBUF (NB_FRAME_SIZE+NB_PITCH_END+2)
#define NB_DEC_BUFFER (NB_FRAME_SIZE+2*NB_PITCH_END+NB_SUBFRAME_SIZE+12)

typedef struct EncState {
   const SpeexMode *mode;        
   int    first;                 

   spx_word32_t cumul_gain;      
   int    bounded_pitch;         
   int    ol_pitch;              
   int    ol_voiced;             
   int   pitch[NB_NB_SUBFRAMES];

#ifdef VORBIS_PSYCHO
   VorbisPsy *psy;
   float *psy_window;
   float *curve;
   float *old_curve;
#endif

   spx_word16_t  gamma1;         
   spx_word16_t  gamma2;         
   spx_word16_t  lpc_floor;      
   char  *stack;                 
   spx_word16_t winBuf[NB_WINDOW_SIZE-NB_FRAME_SIZE];         
   spx_word16_t excBuf[NB_EXCBUF];         
   spx_word16_t *exc;            
   spx_word16_t swBuf[NB_EXCBUF];          
   spx_word16_t *sw;             
   const spx_word16_t *window;   
   const spx_word16_t *lagWindow;      
   spx_lsp_t old_lsp[NB_ORDER];           
   spx_lsp_t old_qlsp[NB_ORDER];          
   spx_mem_t mem_sp[NB_ORDER];            
   spx_mem_t mem_sw[NB_ORDER];            
   spx_mem_t mem_sw_whole[NB_ORDER];      
   spx_mem_t mem_exc[NB_ORDER];           
   spx_mem_t mem_exc2[NB_ORDER];          
   spx_mem_t mem_hp[2];          
   spx_word32_t pi_gain[NB_NB_SUBFRAMES];        
   spx_word16_t *innov_rms_save; 

#ifndef DISABLE_VBR
   VBRState vbr;                
   float  vbr_quality;           
   float  relative_quality;      
   spx_int32_t vbr_enabled;      
   spx_int32_t vbr_max;          
   int    vad_enabled;           
   int    dtx_enabled;           
   int    dtx_count;             
   spx_int32_t abr_enabled;      
   float  abr_drift;
   float  abr_drift2;
   float  abr_count;
#endif 
   
   int    complexity;            
   spx_int32_t sampling_rate;
   int    plc_tuning;
   int    encode_submode;
   const SpeexSubmode * const *submodes; 
   int    submodeID;             
   int    submodeSelect;         
   int    isWideband;            
   int    highpass_enabled;        
} EncState;


typedef struct DecState {
   const SpeexMode *mode;       
   int    first;                
   int    count_lost;           
   spx_int32_t sampling_rate;

   spx_word16_t  last_ol_gain;  

   char  *stack;                
   spx_word16_t excBuf[NB_DEC_BUFFER];        
   spx_word16_t *exc;           
   spx_lsp_t old_qlsp[NB_ORDER];         
   spx_coef_t interp_qlpc[NB_ORDER];     
   spx_mem_t mem_sp[NB_ORDER];           
   spx_mem_t mem_hp[2];         
   spx_word32_t pi_gain[NB_NB_SUBFRAMES];       
   spx_word16_t *innov_save;    
   
   spx_word16_t level;
   spx_word16_t max_level;
   spx_word16_t min_level;
   
   
   int    last_pitch;           
   spx_word16_t  last_pitch_gain; 
   spx_word16_t  pitch_gain_buf[3]; 
   int    pitch_gain_buf_idx;   
   spx_int32_t seed;            
   
   int    encode_submode;
   const SpeexSubmode * const *submodes; 
   int    submodeID;            
   int    lpc_enh_enabled;      
   SpeexCallback speex_callbacks[SPEEX_MAX_CALLBACKS];

   SpeexCallback user_callback;

   
   spx_word16_t  voc_m1;
   spx_word32_t  voc_m2;
   spx_word16_t  voc_mean;
   int    voc_offset;

   int    dtx_enabled;
   int    isWideband;            
   int    highpass_enabled;        
} DecState;


void *nb_encoder_init(const SpeexMode *m);


void nb_encoder_destroy(void *state);


int nb_encode(void *state, void *in, SpeexBits *bits);



void *nb_decoder_init(const SpeexMode *m);


void nb_decoder_destroy(void *state);


int nb_decode(void *state, SpeexBits *bits, void *out);


int nb_encoder_ctl(void *state, int request, void *ptr);


int nb_decoder_ctl(void *state, int request, void *ptr);


#endif
