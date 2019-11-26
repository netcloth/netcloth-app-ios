

#include "bfin.h"

#define OVERRIDE_COMPUTE_WEIGHTED_CODEBOOK 
void compute_weighted_codebook(const signed char *shape_cb, const spx_word16_t *r, spx_word16_t *resp, spx_word16_t *resp2, spx_word32_t *E, int shape_cb_size, int subvect_size, char *stack)
{
   int i;
   for (i=0;i<shape_cb_size;i++)
   {
      __asm__ __volatile__ (
         "P0 = %0;\n\t"
         "LC0 = P0;\n\t"
         "P1 = %1;\n\t"
         "P2 = %2;\n\t"
         "P3 = %3;\n\t"
         "P0 = 1;\n\t"
         "L0 = 0;\n\t"
         "L1 = 0;\n\t"
         "R2 = 0;\n\t"
         "A1 = 0;\n\t"
         "LOOP outter%= LC0;\n\t"
         "LOOP_BEGIN outter%=;\n\t"
            "A0 = 0;\n\t"
            "P4 = P1;\n\t"
            "I1 = P2;\n\t"
            "R0 = B[P4++] (X) || R1.L = W[I1--];\n\t"
            "LOOP inner%= LC1 = P0;\n\t"
            "LOOP_BEGIN inner%=;\n\t"
               "A0 += R0.L*R1.L (IS) || R0 = B[P4++] (X) || R1.L = W[I1--];\n\t"
            "LOOP_END inner%=;\n\t"
            "R0 = A0;\n\t"
            "R0 >>>= 13;\n\t"
            "A1 += R0.L*R0.L (IS);\n\t"
            "W[P3++] = R0;\n\t"
            "P0 += 1;\n\t"
            "P2 += 2;\n\t"
         "LOOP_END outter%=;\n\t"
         "P4 = %4;\n\t"
         "R1 = A1;\n\t"
         "[P4] = R1;\n\t"
         :
      : "m" (subvect_size), "m" (shape_cb), "m" (r), "m" (resp), "m" (E)
      : "A0", "P0", "P1", "P2", "P3", "P4", "R0", "R1", "R2", "I0", "I1", "L0", 
        "L1", "A0", "A1", "memory", "ASTAT" BFIN_HWLOOP0_REGS BFIN_HWLOOP1_REGS
      );
      shape_cb += subvect_size;
      resp += subvect_size;
      E++;
   }
}

#define OVERRIDE_TARGET_UPDATE
static inline void target_update(spx_word16_t *t, spx_word16_t g, spx_word16_t *r, int len)
{
   if (!len)
      return;
   __asm__ __volatile__
         (
         "I0 = %0;\n\t"
         "I1 = %1;\n\t"
         "L0 = 0;\n\t"
         "L1 = 0;\n\t"
         "R2 = 4096;\n\t"
         "LOOP tupdate%= LC0 = %3;\n\t"
         "LOOP_BEGIN tupdate%=;\n\t"
            "R0.L = W[I0] || R1.L = W[I1++];\n\t"
            "R1 = (A1 = R1.L*%2.L) (IS);\n\t"
            "R1 = R1 + R2;\n\t"
            "R1 >>>= 13;\n\t"
            "R0.L = R0.L - R1.L;\n\t"
            "W[I0++] = R0.L;\n\t"
         "LOOP_END tupdate%=;\n\t"
   :
   : "a" (t), "a" (r), "d" (g), "a" (len)
   : "R0", "R1", "R2", "A1", "I0", "I1", "L0", "L1", "ASTAT" BFIN_HWLOOP0_REGS
         );
}
