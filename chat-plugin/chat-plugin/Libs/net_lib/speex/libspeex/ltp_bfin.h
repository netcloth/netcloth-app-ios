

#include "bfin.h"

#define OVERRIDE_INNER_PROD
spx_word32_t inner_prod(const spx_word16_t *x, const spx_word16_t *y, int len)
{
   spx_word32_t sum=0;
   __asm__ __volatile__ (
      "P0 = %3;\n\t"
      "P1 = %1;\n\t"
      "P2 = %2;\n\t"
      "I0 = P1;\n\t"
      "I1 = P2;\n\t"
      "L0 = 0;\n\t"
      "L1 = 0;\n\t"
      "A0 = 0;\n\t"
      "R0.L = W[I0++] || R1.L = W[I1++];\n\t"
      "LOOP inner%= LC0 = P0;\n\t"
      "LOOP_BEGIN inner%=;\n\t"
         "A0 += R0.L*R1.L (IS) || R0.L = W[I0++] || R1.L = W[I1++];\n\t"
      "LOOP_END inner%=;\n\t"
      "A0 += R0.L*R1.L (IS);\n\t"
      "A0 = A0 >>> 6;\n\t"
      "R0 = A0;\n\t"
      "%0 = R0;\n\t"
   : "=m" (sum)
   : "m" (x), "m" (y), "d" (len-1)
   : "P0", "P1", "P2", "R0", "R1", "A0", "I0", "I1", "L0", "L1", "R3", "ASTAT" BFIN_HWLOOP0_REGS
   );
   return sum;
}

#define OVERRIDE_PITCH_XCORR
void pitch_xcorr(const spx_word16_t *_x, const spx_word16_t *_y, spx_word32_t *corr, int len, int nb_pitch, char *stack)
{
   corr += nb_pitch - 1;
   __asm__ __volatile__ (
      "P2 = %0;\n\t"
      "I0 = P2;\n\t" 
      "B0 = P2;\n\t" 
      "R0 = %3;\n\t" 
      "P3 = %3;\n\t"
      "P3 += -2;\n\t" 
      "P4 = %4;\n\t" 
      "R1 = R0 << 1;\n\t" 
      "L0 = R1;\n\t"
      "P0 = %1;\n\t"

      "P1 = %2;\n\t"
      "B1 = P1;\n\t"
      "L1 = 0;\n\t" 

      "r0 = [I0++];\n\t"
      "LOOP pitch%= LC0 = P4 >> 1;\n\t"
      "LOOP_BEGIN pitch%=;\n\t"
         "I1 = P0;\n\t"
         "A1 = A0 = 0;\n\t"
         "R1 = [I1++];\n\t"
         "LOOP inner_prod%= LC1 = P3 >> 1;\n\t"
         "LOOP_BEGIN inner_prod%=;\n\t"
            "A1 += R0.L*R1.H, A0 += R0.L*R1.L (IS) || R1.L = W[I1++];\n\t"
            "A1 += R0.H*R1.L, A0 += R0.H*R1.H (IS) || R1.H = W[I1++] || R0 = [I0++];\n\t"
         "LOOP_END inner_prod%=;\n\t"
         "A1 += R0.L*R1.H, A0 += R0.L*R1.L (IS) || R1.L = W[I1++];\n\t"
         "A1 += R0.H*R1.L, A0 += R0.H*R1.H (IS) || R0 = [I0++];\n\t"
         "A0 = A0 >>> 6;\n\t"
         "A1 = A1 >>> 6;\n\t"
         "R2 = A0, R3 = A1;\n\t"
         "[P1--] = r2;\n\t"
         "[P1--] = r3;\n\t"
         "P0 += 4;\n\t"
      "LOOP_END pitch%=;\n\t"
      "L0 = 0;\n\t"
   : : "m" (_x), "m" (_y), "m" (corr), "m" (len), "m" (nb_pitch)
   : "A0", "A1", "P0", "P1", "P2", "P3", "P4", "R0", "R1", "R2", "R3", "I0", "I1", "L0", "L1", "B0", "B1", "memory",
     "ASTAT" BFIN_HWLOOP0_REGS BFIN_HWLOOP1_REGS
   );
}

#define OVERRIDE_COMPUTE_PITCH_ERROR
static inline spx_word32_t compute_pitch_error(spx_word16_t *C, spx_word16_t *g, spx_word16_t pitch_control)
{
   spx_word32_t sum;
   __asm__ __volatile__
         (
         "A0 = 0;\n\t"
         
         "R0 = W[%1++];\n\t"
         "R1.L = %2.L*%5.L (IS);\n\t"
         "A0 += R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %3.L*%5.L (IS);\n\t"
         "A0 += R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %4.L*%5.L (IS);\n\t"
         "A0 += R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %2.L*%3.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS) || R0 = W[%1++];\n\t"

         "R1.L = %4.L*%3.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %4.L*%2.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %2.L*%2.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS) || R0 = W[%1++];\n\t"

         "R1.L = %3.L*%3.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS) || R0 = W[%1++];\n\t"
         
         "R1.L = %4.L*%4.L (IS);\n\t"
         "A0 -= R1.L*R0.L (IS);\n\t"
         
         "%0 = A0;\n\t"
   : "=&D" (sum), "=a" (C)
   : "d" (g[0]), "d" (g[1]), "d" (g[2]), "d" (pitch_control), "1" (C)
   : "R0", "R1", "R2", "A0", "ASTAT"
         );
   return sum;
}

#define OVERRIDE_OPEN_LOOP_NBEST_PITCH
#ifdef OVERRIDE_OPEN_LOOP_NBEST_PITCH
void open_loop_nbest_pitch(spx_word16_t *sw, int start, int end, int len, int *pitch, spx_word16_t *gain, int N, char *stack)
{
   int i,j,k;
   VARDECL(spx_word32_t *best_score);
   VARDECL(spx_word32_t *best_ener);
   spx_word32_t e0;
   VARDECL(spx_word32_t *corr);
   VARDECL(spx_word32_t *energy);

   ALLOC(best_score, N, spx_word32_t);
   ALLOC(best_ener, N, spx_word32_t);
   ALLOC(corr, end-start+1, spx_word32_t);
   ALLOC(energy, end-start+2, spx_word32_t);

   for (i=0;i<N;i++)
   {
        best_score[i]=-1;
        best_ener[i]=0;
        pitch[i]=start;
   }

   energy[0]=inner_prod(sw-start, sw-start, len);
   e0=inner_prod(sw, sw, len);

   

      __asm__ __volatile__
      (
"        P0 = %0;\n\t"
"        I1 = %1;\n\t"
"        L1 = 0;\n\t"
"        I2 = %2;\n\t"
"        L2 = 0;\n\t"
"        R2 = [P0++];\n\t"
"        R3 = 0;\n\t"
"        LSETUP (eu1, eu2) LC1 = %3;\n\t"
"eu1:      R1.L = W [I1--] || R0.L = W [I2--] ;\n\t"
"          R1 = R1.L * R1.L (IS);\n\t"
"          R0 = R0.L * R0.L (IS);\n\t"
"          R1 >>>= 6;\n\t"
"          R1 = R1 + R2;\n\t"
"          R0 >>>= 6;\n\t"
"          R1 = R1 - R0;\n\t"
"          R2 = MAX(R1,R3);\n\t"
"eu2:      [P0++] = R2;\n\t"
       : : "d" (energy), "d" (&sw[-start-1]), "d" (&sw[-start+len-1]),
           "a" (end-start)  
       : "P0", "I1", "I2", "R0", "R1", "R2", "R3", "ASTAT" BFIN_HWLOOP1_REGS
       );

   pitch_xcorr(sw, sw-end, corr, len, end-start+1, stack);

   
   {
      VARDECL(spx_word16_t *corr16);
      VARDECL(spx_word16_t *ener16);
      ALLOC(corr16, end-start+1, spx_word16_t);
      ALLOC(ener16, end-start+1, spx_word16_t);
      
      normalize16(corr, corr16, 180, end-start+1);
      normalize16(energy, ener16, 180, end-start+1);

      if (N == 1) {
	
      __asm__ __volatile__
      (
"        I0 = %1;\n\t"                     
"        L0 = 0;\n\t"
"        I1 = %2;\n\t"                     
"        L1 = 0;\n\t"
"        R2 = -1;\n\t"                     
"        R3 = 0;\n\t"                      
"        P0 = %4;\n\t"                     
"        P1 = %4;\n\t"                     
"        LSETUP (sl1, sl2) LC1 = %3;\n\t"
"sl1:      R0.L = W [I0++] || R1.L = W [I1++];\n\t"         
"          R0 = R0.L * R0.L (IS);\n\t"
"          R1   += 1;\n\t"
"          R4   = R0.L * R3.L;\n\t"
"          R5   = R2.L * R1.L;\n\t"
"          cc   = R5 < R4;\n\t"
"          if cc R2 = R0;\n\t"
"          if cc R3 = R1;\n\t"
"          if cc P0 = P1;\n\t"
"sl2:      P1 += 1;\n\t"
"        %0 = P0;\n\t"
       : "=&d" (pitch[0])
       : "a" (corr16), "a" (ener16), "a" (end+1-start), "d" (start) 
       : "P0", "P1", "I0", "I1", "R0", "R1", "R2", "R3", "R4", "R5",
         "ASTAT", "CC" BFIN_HWLOOP1_REGS
       );

      }
      else {
	for (i=start;i<=end;i++)
	  {
	    spx_word16_t tmp = MULT16_16_16(corr16[i-start],corr16[i-start]);
	    
	    if (MULT16_16(tmp,best_ener[N-1])>MULT16_16(best_score[N-1],ADD16(1,ener16[i-start])))
	      {
		
		best_score[N-1]=tmp;
		best_ener[N-1]=ener16[i-start]+1;
		pitch[N-1]=i;
		
		for (j=0;j<N-1;j++)
		  {
		    if (MULT16_16(tmp,best_ener[j])>MULT16_16(best_score[j],ADD16(1,ener16[i-start])))
		      {
			for (k=N-1;k>j;k--)
			  {
			    best_score[k]=best_score[k-1];
			    best_ener[k]=best_ener[k-1];
			    pitch[k]=pitch[k-1];
			  }
			best_score[j]=tmp;
			best_ener[j]=ener16[i-start]+1;
			pitch[j]=i;
			break;
		      }
		  }
	      }
	  }
      }
   }

   
   if (gain)
   {
       for (j=0;j<N;j++)
       {
          spx_word16_t g;
          i=pitch[j];
          g = DIV32(corr[i-start], 10+SHR32(MULT16_16(spx_sqrt(e0),spx_sqrt(energy[i-start])),6));
          
                   if (g<0)
                   g = 0;
             gain[j]=g;
       }
   }
}
#endif

#define OVERRIDE_PITCH_GAIN_SEARCH_3TAP_VQ
#ifdef OVERRIDE_PITCH_GAIN_SEARCH_3TAP_VQ
static int pitch_gain_search_3tap_vq(
  const signed char *gain_cdbk,
  int                gain_cdbk_size,
  spx_word16_t      *C16,
  spx_word16_t       max_gain
)
{
  const signed char *ptr=gain_cdbk;
  int                best_cdbk=0;
  spx_word32_t       best_sum=-VERY_LARGE32;
  spx_word32_t       sum=0;
  spx_word16_t       g[3];
  spx_word16_t       pitch_control=64;
  spx_word16_t       gain_sum;
  int                i;

      

      __asm__ __volatile__
      (

"        P0 = %2;\n\t"                     
"        L1 = 0;\n\t"                      
"        %0 = 0;\n\t"                      
"        %1 = 0;\n\t"                      
"        P1 = 0;\n\t"                      

"        LSETUP (pgs1, pgs2) LC1 = %4;\n\t"
"pgs1:     R2  = B [P0++] (X);\n\t"        
"          R3  = B [P0++] (X);\n\t"        
"          R4  = B [P0++] (X);\n\t"        
"          R2 += 32;\n\t"
"          R3 += 32;\n\t"
"          R4 += 32;\n\t"
"          R4.H = 64;\n\t"                 

"          R0  = B [P0++] (X);\n\t"              
"          B0  = R0;\n\t"                  
          
           

"          I1 = %3;\n\t"                   
"          A0 = 0;\n\t"
         
"          R0.L = W[I1++];\n\t"
"          R1.L = R2.L*R4.H (IS);\n\t"
"          A0 += R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R3.L*R4.H (IS);\n\t"
"          A0 += R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R4.L*R4.H (IS);\n\t"
"          A0 += R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R2.L*R3.L (IS);\n\t"
"          A0 -= R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"

"          R1.L = R4.L*R3.L (IS);\n\t"
"          A0 -= R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R4.L*R2.L (IS);\n\t"
"          A0 -= R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R2.L*R2.L (IS);\n\t"
"          A0 -= R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"

"          R1.L = R3.L*R3.L (IS);\n\t"
"          A0 -= R1.L*R0.L (IS) || R0.L = W[I1++];\n\t"
         
"          R1.L = R4.L*R4.L (IS);\n\t"
"          R0 = (A0 -= R1.L*R0.L) (IS);\n\t"

"          R1 = B0\n\t"
"          R2 = %5\n\t"
"          R3 = %6\n\t"
"          cc = R2 <= R1;\n\t" 
"          if cc R0 = R3;\n\t"
"          cc = %0 <= R0;\n\t"
"          if cc %0 = R0;\n\t"
"          if cc %1 = P1;\n\t"

"pgs2:     P1 += 1;\n\t"
   
       : "=&d" (best_sum), "=&d" (best_cdbk) 
       : "a" (gain_cdbk), "a" (C16), "a" (gain_cdbk_size), "a" (max_gain),
         "b" (-VERY_LARGE32)
       : "R0", "R1", "R2", "R3", "R4", "P0", 
         "P1", "I1", "L1", "A0", "B0", "CC", "ASTAT" BFIN_HWLOOP1_REGS
       );

  return best_cdbk;
}
#endif

