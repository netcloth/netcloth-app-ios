
#ifndef __AK2LSPD__
#define __AK2LSPD__

#include "arch.h"

int lpc_to_lsp (spx_coef_t *a, int lpcrdr, spx_lsp_t *freq, int nb, spx_word16_t delta, char *stack);
void lsp_to_lpc(const spx_lsp_t *freq, spx_coef_t *ak, int lpcrdr, char *stack);


void lsp_interpolate(spx_lsp_t *old_lsp, spx_lsp_t *new_lsp, spx_lsp_t *interp_lsp, int len, int subframe, int nb_subframes, spx_word16_t margin);

#endif	
