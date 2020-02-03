/* Copyright (C) 2002-2006 Jean-Marc Valin
   File: modes.c

   Describes the different modes of the codec

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   - Neither the name of the Xiph.org Foundation nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "modes.h"
#include "ltp.h"
#include "quant_lsp.h"
#include "cb_search.h"
#include "sb_celp.h"
#include "nb_celp.h"
#include "vbr.h"
#include "arch.h"
#include <math.h>

#ifndef NULL
#define NULL 0
#endif

#ifdef DISABLE_ENCODER
#define nb_encoder_init NULL
#define nb_encoder_destroy NULL
#define nb_encode NULL
#define nb_encoder_ctl NULL

#define split_cb_search_shape_sign NULL
#define noise_codebook_quant NULL
#define pitch_search_3tap NULL
#define forced_pitch_quant NULL
#define lsp_quant_nb NULL
#define lsp_quant_lbr NULL
#endif  

#ifdef DISABLE_DECODER
#define nb_decoder_init NULL
#define nb_decoder_destroy NULL
#define nb_decode NULL
#define nb_decoder_ctl NULL

#define noise_codebook_unquant NULL
#define split_cb_shape_sign_unquant NULL
#define lsp_unquant_nb NULL
#define lsp_unquant_lbr NULL
#define pitch_unquant_3tap NULL
#define forced_pitch_unquant NULL
#endif  

 
extern const signed char gain_cdbk_nb[];
extern const signed char gain_cdbk_lbr[];
extern const signed char exc_5_256_table[];
extern const signed char exc_5_64_table[];
extern const signed char exc_8_128_table[];
extern const signed char exc_10_32_table[];
extern const signed char exc_10_16_table[];
extern const signed char exc_20_32_table[];


/* Parameters for Long-Term Prediction (LTP)*/
static const ltp_params ltp_params_nb = {
   gain_cdbk_nb,
   7,
   7
};

/* Parameters for Long-Term Prediction (LTP)*/
static const ltp_params ltp_params_vlbr = {
   gain_cdbk_lbr,
   5,
   0
};

/* Parameters for Long-Term Prediction (LTP)*/
static const ltp_params ltp_params_lbr = {
   gain_cdbk_lbr,
   5,
   7
};

/* Parameters for Long-Term Prediction (LTP)*/
static const ltp_params ltp_params_med = {
   gain_cdbk_lbr,
   5,
   7
};

/* Split-VQ innovation parameters for very low bit-rate narrowband */
static const split_cb_params split_cb_nb_vlbr = {
   10,                
   4,                
   exc_10_16_table,  
   4,                
   0,
};

/* Split-VQ innovation parameters for very low bit-rate narrowband */
static const split_cb_params split_cb_nb_ulbr = {
   20,                
   2,                
   exc_20_32_table,  
   5,                
   0,
};

/* Split-VQ innovation parameters for low bit-rate narrowband */
static const split_cb_params split_cb_nb_lbr = {
   10,               
   4,                
   exc_10_32_table,  
   5,                
   0,
};


/* Split-VQ innovation parameters narrowband */
static const split_cb_params split_cb_nb = {
   5,                
   8,                
   exc_5_64_table,  
   6,                
   0,
};

/* Split-VQ innovation parameters narrowband */
static const split_cb_params split_cb_nb_med = {
   8,                
   5,                
   exc_8_128_table,  
   7,                
   0,
};

/* Split-VQ innovation for low-band wideband */
static const split_cb_params split_cb_sb = {
   5,                
   8,               
   exc_5_256_table,     
   8,                
   0,
};



/* 2150 bps "vocoder-like" mode for comfort noise */
static const SpeexSubmode nb_submode1 = {
   0,
   1,
   0,
   0,
    
   lsp_quant_lbr,
   lsp_unquant_lbr,
    
   forced_pitch_quant,
   forced_pitch_unquant,
   NULL,
   /* No innovation quantization (noise only) */
   noise_codebook_quant,
   noise_codebook_unquant,
   NULL,
   -1,
   43
};

/* 3.95 kbps very low bit-rate mode */
static const SpeexSubmode nb_submode8 = {
   0,
   1,
   0,
   0,
    
   lsp_quant_lbr,
   lsp_unquant_lbr,
    
   forced_pitch_quant,
   forced_pitch_unquant,
   NULL,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb_ulbr,
   QCONST16(.5,15),
   79
};

/* 5.95 kbps very low bit-rate mode */
static const SpeexSubmode nb_submode2 = {
   0,
   0,
   0,
   0,
    
   lsp_quant_lbr,
   lsp_unquant_lbr,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_vlbr,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb_vlbr,
   QCONST16(.6,15),
   119
};

/* 8 kbps low bit-rate mode */
static const SpeexSubmode nb_submode3 = {
   -1,
   0,
   1,
   0,
    
   lsp_quant_lbr,
   lsp_unquant_lbr,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_lbr,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb_lbr,
   QCONST16(.55,15),
   160
};

/* 11 kbps medium bit-rate mode */
static const SpeexSubmode nb_submode4 = {
   -1,
   0,
   1,
   0,
    
   lsp_quant_lbr,
   lsp_unquant_lbr,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_med,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb_med,
   QCONST16(.45,15),
   220
};

/* 15 kbps high bit-rate mode */
static const SpeexSubmode nb_submode5 = {
   -1,
   0,
   3,
   0,
    
   lsp_quant_nb,
   lsp_unquant_nb,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_nb,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb,
   QCONST16(.25,15),
   300
};

/* 18.2 high bit-rate mode */
static const SpeexSubmode nb_submode6 = {
   -1,
   0,
   3,
   0,
    
   lsp_quant_nb,
   lsp_unquant_nb,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_nb,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_sb,
   QCONST16(.15,15),
   364
};

/* 24.6 kbps high bit-rate mode */
static const SpeexSubmode nb_submode7 = {
   -1,
   0,
   3,
   1,
    
   lsp_quant_nb,
   lsp_unquant_nb,
    
   pitch_search_3tap,
   pitch_unquant_3tap,
   &ltp_params_nb,
    
   split_cb_search_shape_sign,
   split_cb_shape_sign_unquant,
   &split_cb_nb,
   QCONST16(.05,15),
   492
};


 
static const SpeexNBMode nb_mode = {
   NB_FRAME_SIZE,     
   NB_SUBFRAME_SIZE,  
   NB_ORDER,          
   NB_PITCH_START,                
   NB_PITCH_END,               
   QCONST16(0.92,15),   
   QCONST16(0.6,15),    
   QCONST16(.0002,15),  
   {NULL, &nb_submode1, &nb_submode2, &nb_submode3, &nb_submode4, &nb_submode5, &nb_submode6, &nb_submode7,
   &nb_submode8, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
   5,
   {1, 8, 2, 3, 3, 4, 4, 5, 5, 6, 7}
};


 
EXPORT const SpeexMode speex_nb_mode = {
   &nb_mode,
   nb_mode_query,
   "narrowband",
   0,
   4,
   nb_encoder_init,
   nb_encoder_destroy,
   nb_encode,
   nb_decoder_init,
   nb_decoder_destroy,
   nb_decode,
   nb_encoder_ctl,
   nb_decoder_ctl,
};



EXPORT int speex_mode_query(const SpeexMode *mode, int request, void *ptr)
{
   return mode->query(mode->mode, request, ptr);
}

#ifdef FIXED_DEBUG
long long spx_mips=0;
#endif

