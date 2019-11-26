

#include "bfin.h"

#define OVERRIDE_SPEEX_MOVE
void *speex_move (void *dest, void *src, int n)
{
   __asm__ __volatile__
         (
         "L0 = 0;\n\t"
         "I0 = %0;\n\t"
         "R0 = [I0++];\n\t"
         "LOOP move%= LC0 = %2;\n\t"
         "LOOP_BEGIN move%=;\n\t"
            "[%1++] = R0 || R0 = [I0++];\n\t"
         "LOOP_END move%=;\n\t"
         "[%1++] = R0;\n\t"
   : "=a" (src), "=a" (dest)
   : "a" ((n>>2)-1), "0" (src), "1" (dest)
   : "R0", "I0", "L0", "memory" BFIN_HWLOOP0_REGS
         );
   return dest;
}
