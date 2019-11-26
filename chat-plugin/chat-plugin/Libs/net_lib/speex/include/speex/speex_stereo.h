

#ifndef STEREO_H
#define STEREO_H

#include "speex_types.h"
#include "speex_bits.h"


#ifdef __cplusplus
extern "C" {
#endif


typedef struct SpeexStereoState {
   float balance;      
   float e_ratio;      
   float smooth_left;  
   float smooth_right; 
   float reserved1;    
   float reserved2;    
} SpeexStereoState;


#define SPEEX_STEREO_STATE_INIT {1,.5,1,1,0,0}


SpeexStereoState *speex_stereo_state_init(void);


void speex_stereo_state_reset(SpeexStereoState *stereo);


void speex_stereo_state_destroy(SpeexStereoState *stereo);


void speex_encode_stereo(float *data, int frame_size, SpeexBits *bits);


void speex_encode_stereo_int(spx_int16_t *data, int frame_size, SpeexBits *bits);


void speex_decode_stereo(float *data, int frame_size, SpeexStereoState *stereo);


void speex_decode_stereo_int(spx_int16_t *data, int frame_size, SpeexStereoState *stereo);


int speex_std_stereo_request_handler(SpeexBits *bits, void *state, void *data);

#ifdef __cplusplus
}
#endif


#endif
