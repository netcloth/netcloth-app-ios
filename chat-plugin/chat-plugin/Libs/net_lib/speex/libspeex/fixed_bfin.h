
#ifndef FIXED_BFIN_H
#define FIXED_BFIN_H

#include "bfin.h"

#undef PDIV32_16
static inline spx_word16_t PDIV32_16(spx_word32_t a, spx_word16_t b)
{
   spx_word32_t res, bb;
   bb = b;
   a += b>>1;
   __asm__  (
         "P0 = 15;\n\t"
         "R0 = %1;\n\t"
         "R1 = %2;\n\t"

         "R0 <<= 1;\n\t"
         "DIVS (R0, R1);\n\t"
         "LOOP divide%= LC0 = P0;\n\t"
         "LOOP_BEGIN divide%=;\n\t"
            "DIVQ (R0, R1);\n\t"
         "LOOP_END divide%=;\n\t"
         "R0 = R0.L;\n\t"
         "%0 = R0;\n\t"
   : "=m" (res)
   : "m" (a), "m" (bb)
   : "P0", "R0", "R1", "ASTAT" BFIN_HWLOOP0_REGS);
   return res;
}

#undef DIV32_16
static inline spx_word16_t DIV32_16(spx_word32_t a, spx_word16_t b)
{
   spx_word32_t res, bb;
   bb = b;
   if (a<0) 
      a += (b-1);
   __asm__  (
         "P0 = 15;\n\t"
         "R0 = %1;\n\t"
         "R1 = %2;\n\t"
         "R0 <<= 1;\n\t"
         "DIVS (R0, R1);\n\t"
         "LOOP divide%= LC0 = P0;\n\t"
         "LOOP_BEGIN divide%=;\n\t"
            "DIVQ (R0, R1);\n\t"
         "LOOP_END divide%=;\n\t"
         "R0 = R0.L;\n\t"
         "%0 = R0;\n\t"
   : "=m" (res)
   : "m" (a), "m" (bb)
   : "P0", "R0", "R1", "ASTAT" BFIN_HWLOOP0_REGS);
   return res;
}

#undef MAX16
static inline spx_word16_t MAX16(spx_word16_t a, spx_word16_t b)
{
   spx_word32_t res;
   __asm__  (
         "%1 = %1.L (X);\n\t"
         "%2 = %2.L (X);\n\t"
         "%0 = MAX(%1,%2);"
   : "=d" (res)
   : "%d" (a), "d" (b)
   : "ASTAT"
   );
   return res;
}

#undef MULT16_32_Q15
static inline spx_word32_t MULT16_32_Q15(spx_word16_t a, spx_word32_t b)
{
   spx_word32_t res;
   __asm__
   (
         "A1 = %2.L*%1.L (M);\n\t"
         "A1 = A1 >>> 15;\n\t"
         "%0 = (A1 += %2.L*%1.H) ;\n\t"
   : "=&W" (res), "=&d" (b)
   : "d" (a), "1" (b)
   : "A1", "ASTAT"
   );
   return res;
}

#undef MAC16_32_Q15
static inline spx_word32_t MAC16_32_Q15(spx_word32_t c, spx_word16_t a, spx_word32_t b)
{
   spx_word32_t res;
   __asm__
         (
         "A1 = %2.L*%1.L (M);\n\t"
         "A1 = A1 >>> 15;\n\t"
         "%0 = (A1 += %2.L*%1.H);\n\t"
         "%0 = %0 + %4;\n\t"
   : "=&W" (res), "=&d" (b)
   : "d" (a), "1" (b), "d" (c)
   : "A1", "ASTAT"
         );
   return res;
}

#undef MULT16_32_Q14
static inline spx_word32_t MULT16_32_Q14(spx_word16_t a, spx_word32_t b)
{
   spx_word32_t res;
   __asm__
         (
         "%2 <<= 1;\n\t"
         "A1 = %1.L*%2.L (M);\n\t"
         "A1 = A1 >>> 15;\n\t"
         "%0 = (A1 += %1.L*%2.H);\n\t"
   : "=W" (res), "=d" (a), "=d" (b)
   : "1" (a), "2" (b)
   : "A1", "ASTAT"
         );
   return res;
}

#undef MAC16_32_Q14
static inline spx_word32_t MAC16_32_Q14(spx_word32_t c, spx_word16_t a, spx_word32_t b)
{
   spx_word32_t res;
   __asm__
         (
         "%1 <<= 1;\n\t"
         "A1 = %2.L*%1.L (M);\n\t"
         "A1 = A1 >>> 15;\n\t"
         "%0 = (A1 += %2.L*%1.H);\n\t"
         "%0 = %0 + %4;\n\t"
   : "=&W" (res), "=&d" (b)
   : "d" (a), "1" (b), "d" (c)
   : "A1", "ASTAT"
         );
   return res;
}

#endif
