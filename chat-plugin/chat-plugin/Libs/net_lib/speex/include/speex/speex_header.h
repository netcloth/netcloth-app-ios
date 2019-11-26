


#ifndef SPEEX_HEADER_H
#define SPEEX_HEADER_H

#include "speex_types.h"

#ifdef __cplusplus
extern "C" {
#endif

struct SpeexMode;


#define SPEEX_HEADER_STRING_LENGTH 8


#define SPEEX_HEADER_VERSION_LENGTH 20


typedef struct SpeexHeader {
   char speex_string[SPEEX_HEADER_STRING_LENGTH];   
   char speex_version[SPEEX_HEADER_VERSION_LENGTH]; 
   spx_int32_t speex_version_id;       
   spx_int32_t header_size;            
   spx_int32_t rate;                   
   spx_int32_t mode;                   
   spx_int32_t mode_bitstream_version; 
   spx_int32_t nb_channels;            
   spx_int32_t bitrate;                
   spx_int32_t frame_size;             
   spx_int32_t vbr;                    
   spx_int32_t frames_per_packet;      
   spx_int32_t extra_headers;          
   spx_int32_t reserved1;              
   spx_int32_t reserved2;              
} SpeexHeader;


void speex_init_header(SpeexHeader *header, int rate, int nb_channels, const struct SpeexMode *m);


char *speex_header_to_packet(SpeexHeader *header, int *size);


SpeexHeader *speex_packet_to_header(char *packet, int size);


void speex_header_free(void *ptr);

#ifdef __cplusplus
}
#endif


#endif
