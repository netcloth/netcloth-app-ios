

#ifndef QUANT_LSP_H
#define QUANT_LSP_H

#include "speex/speex_bits.h"
#include "arch.h"

#define MAX_LSP_SIZE 20

#define NB_CDBK_SIZE 64
#define NB_CDBK_SIZE_LOW1 64
#define NB_CDBK_SIZE_LOW2 64
#define NB_CDBK_SIZE_HIGH1 64
#define NB_CDBK_SIZE_HIGH2 64


extern const signed char cdbk_nb[];
extern const signed char cdbk_nb_low1[];
extern const signed char cdbk_nb_low2[];
extern const signed char cdbk_nb_high1[];
extern const signed char cdbk_nb_high2[];


void lsp_quant_nb(spx_lsp_t *lsp, spx_lsp_t *qlsp, int order, SpeexBits *bits);


void lsp_unquant_nb(spx_lsp_t *lsp, int order, SpeexBits *bits);


void lsp_quant_lbr(spx_lsp_t *lsp, spx_lsp_t *qlsp, int order, SpeexBits *bits);


void lsp_unquant_lbr(spx_lsp_t *lsp, int order, SpeexBits *bits);


void lsp_quant_high(spx_lsp_t *lsp, spx_lsp_t *qlsp, int order, SpeexBits *bits);


void lsp_unquant_high(spx_lsp_t *lsp, int order, SpeexBits *bits);

#endif
