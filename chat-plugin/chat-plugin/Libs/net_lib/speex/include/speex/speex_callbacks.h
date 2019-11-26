

#ifndef SPEEX_CALLBACKS_H
#define SPEEX_CALLBACKS_H

#include "speex.h"

#ifdef __cplusplus
extern "C" {
#endif


#define SPEEX_MAX_CALLBACKS 16





#define SPEEX_INBAND_ENH_REQUEST         0

#define SPEEX_INBAND_RESERVED1           1



#define SPEEX_INBAND_MODE_REQUEST        2

#define SPEEX_INBAND_LOW_MODE_REQUEST    3

#define SPEEX_INBAND_HIGH_MODE_REQUEST   4

#define SPEEX_INBAND_VBR_QUALITY_REQUEST 5

#define SPEEX_INBAND_ACKNOWLEDGE_REQUEST 6

#define SPEEX_INBAND_VBR_REQUEST         7



#define SPEEX_INBAND_CHAR                8

#define SPEEX_INBAND_STEREO              9



#define SPEEX_INBAND_MAX_BITRATE         10



#define SPEEX_INBAND_ACKNOWLEDGE         12


typedef int (*speex_callback_func)(SpeexBits *bits, void *state, void *data);


typedef struct SpeexCallback {
   int callback_id;             
   speex_callback_func func;    
   void *data;                  
   void *reserved1;             
   int   reserved2;             
} SpeexCallback;


int speex_inband_handler(SpeexBits *bits, SpeexCallback *callback_list, void *state);


int speex_std_mode_request_handler(SpeexBits *bits, void *state, void *data);


int speex_std_high_mode_request_handler(SpeexBits *bits, void *state, void *data);


int speex_std_char_handler(SpeexBits *bits, void *state, void *data);


int speex_default_user_handler(SpeexBits *bits, void *state, void *data);




int speex_std_low_mode_request_handler(SpeexBits *bits, void *state, void *data);


int speex_std_vbr_request_handler(SpeexBits *bits, void *state, void *data);


int speex_std_enh_request_handler(SpeexBits *bits, void *state, void *data);


int speex_std_vbr_quality_request_handler(SpeexBits *bits, void *state, void *data);


#ifdef __cplusplus
}
#endif


#endif
