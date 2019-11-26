

#define OVERRIDE_CHEB_POLY_EVA
#ifdef OVERRIDE_CHEB_POLY_EVA
static inline spx_word32_t cheb_poly_eva(
  spx_word16_t *coef, 
  spx_word16_t     x, 
  int              m, 
  char         *stack
)
{
    spx_word32_t sum;

   __asm__ __volatile__
     (
      "P0 = %2;\n\t"           
      "R4 = 8192;\n\t"         
      "R2 = %1;\n\t"           

      "R5 = -16383;\n\t"
      "R2 = MAX(R2,R5);\n\t"
      "R5 = 16383;\n\t"
      "R2 = MIN(R2,R5);\n\t"

      "R3 = W[P0--] (X);\n\t"  
      "R5 = W[P0--] (X);\n\t"
      "R5 = R5.L * R2.L (IS);\n\t"
      "R5 = R5 + R4;\n\t"
      "R5 >>>= 14;\n\t"
      "R3 = R3 + R5;\n\t" 
      
      "R0 = R2;\n\t"           
      "R1 = 16384;\n\t"        
      "LOOP cpe%= LC0 = %3;\n\t"
      "LOOP_BEGIN cpe%=;\n\t"
        "P1 = R0;\n\t" 
        "R0 = R2.L * R0.L (IS) || R5 = W[P0--] (X);\n\t"
        "R0 >>>= 13;\n\t"
        "R0 = R0 - R1;\n\t"
        "R1 = P1;\n\t"
        "R5 = R5.L * R0.L (IS);\n\t"
        "R5 = R5 + R4;\n\t"
        "R5 >>>= 14;\n\t"
        "R3 = R3 + R5;\n\t"
      "LOOP_END cpe%=;\n\t"
      "%0 = R3;\n\t"
      : "=&d" (sum)
      : "a" (x), "a" (&coef[m]), "a" (m-1)
      : "R0", "R1", "R3", "R2", "R4", "R5", "P0", "P1", "ASTAT" BFIN_HWLOOP0_REGS
      );
    return sum;
}
#endif



