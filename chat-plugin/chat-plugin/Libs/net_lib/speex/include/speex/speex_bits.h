

#ifndef BITS_H
#define BITS_H

#ifdef __cplusplus
extern "C" {
#endif


typedef struct SpeexBits {
   char *chars;   
   int   nbBits;  
   int   charPtr; 
   int   bitPtr;  
   int   owner;   
   int   overflow;
   int   buf_size;
   int   reserved1; 
   void *reserved2; 
} SpeexBits;


void speex_bits_init(SpeexBits *bits);


void speex_bits_init_buffer(SpeexBits *bits, void *buff, int buf_size);


void speex_bits_set_bit_buffer(SpeexBits *bits, void *buff, int buf_size);


void speex_bits_destroy(SpeexBits *bits);


void speex_bits_reset(SpeexBits *bits);


void speex_bits_rewind(SpeexBits *bits);


void speex_bits_read_from(SpeexBits *bits, const char *bytes, int len);

void speex_bits_read_whole_bytes(SpeexBits *bits, const char *bytes, int len);

int speex_bits_write(SpeexBits *bits, char *bytes, int max_len);


int speex_bits_write_whole_bytes(SpeexBits *bits, char *bytes, int max_len);

void speex_bits_pack(SpeexBits *bits, int data, int nbBits);

int speex_bits_unpack_signed(SpeexBits *bits, int nbBits);

unsigned int speex_bits_unpack_unsigned(SpeexBits *bits, int nbBits);

int speex_bits_nbytes(SpeexBits *bits);

unsigned int speex_bits_peek_unsigned(SpeexBits *bits, int nbBits);

int speex_bits_peek(SpeexBits *bits);

void speex_bits_advance(SpeexBits *bits, int n);

int speex_bits_remaining(SpeexBits *bits);

void speex_bits_insert_terminator(SpeexBits *bits);

#ifdef __cplusplus
}
#endif


#endif
