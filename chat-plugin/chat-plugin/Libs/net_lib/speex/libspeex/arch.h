

#ifndef ARCH_H
#define ARCH_H

#ifndef SPEEX_VERSION
#define SPEEX_MAJOR_VERSION 1         
#define SPEEX_MINOR_VERSION 1         
#define SPEEX_MICRO_VERSION 16        
#define SPEEX_EXTRA_VERSION ""        
#define SPEEX_VERSION "speex-1.2.0"   
#endif


#ifdef FIXED_POINT

#ifdef FLOATING_POINT
#error You cannot compile as floating point and fixed point at the same time
#endif
#ifdef _USE_SSE
#error SSE is only for floating-point
#endif
#if ((defined (ARM4_ASM)||defined (ARM4_ASM)) && defined(BFIN_ASM)) || (defined (ARM4_ASM)&&defined(ARM5E_ASM))
#error Make up your mind. What CPU do you have?
#endif
#ifdef VORBIS_PSYCHO
#error Vorbis-psy model currently not implemented in fixed-point
#endif

#else

#ifndef FLOATING_POINT
#error You now need to define either FIXED_POINT or FLOATING_POINT
#endif
#if defined (ARM4_ASM) || defined(ARM5E_ASM) || defined(BFIN_ASM)
#error I suppose you can have a [ARM4/ARM5E/Blackfin] that has float instructions?
#endif
#ifdef FIXED_POINT_DEBUG
#error "Don't you think enabling fixed-point is a good thing to do if you want to debug that?"
#endif


#endif

#include "speex/speex_types.h"

#define ABS(x) ((x) < 0 ? (-(x)) : (x))      
#define ABS16(x) ((x) < 0 ? (-(x)) : (x))    
#define MIN16(a,b) ((a) < (b) ? (a) : (b))   
#define MAX16(a,b) ((a) > (b) ? (a) : (b))   
#define ABS32(x) ((x) < 0 ? (-(x)) : (x))    
#define MIN32(a,b) ((a) < (b) ? (a) : (b))   
#define MAX32(a,b) ((a) > (b) ? (a) : (b))   

#ifdef FIXED_POINT

typedef spx_int16_t spx_word16_t;
typedef spx_int32_t spx_word32_t;
typedef spx_word32_t spx_mem_t;
typedef spx_word16_t spx_coef_t;
typedef spx_word16_t spx_lsp_t;
typedef spx_word32_t spx_sig_t;

#define Q15ONE 32767

#define LPC_SCALING  8192
#define SIG_SCALING  16384
#define LSP_SCALING  8192.
#define GAMMA_SCALING 32768.
#define GAIN_SCALING 64
#define GAIN_SCALING_1 0.015625

#define LPC_SHIFT    13
#define LSP_SHIFT    13
#define SIG_SHIFT    14
#define GAIN_SHIFT   6

#define VERY_SMALL 0
#define VERY_LARGE32 ((spx_word32_t)2147483647)
#define VERY_LARGE16 ((spx_word16_t)32767)
#define Q15_ONE ((spx_word16_t)32767)


#ifdef FIXED_DEBUG
#include "fixed_debug.h"
#else

#include "fixed_generic.h"

#ifdef ARM5E_ASM
#include "fixed_arm5e.h"
#elif defined (ARM4_ASM)
#include "fixed_arm4.h"
#elif defined (BFIN_ASM)
#include "fixed_bfin.h"
#endif

#endif


#else

typedef float spx_mem_t;
typedef float spx_coef_t;
typedef float spx_lsp_t;
typedef float spx_sig_t;
typedef float spx_word16_t;
typedef float spx_word32_t;

#define Q15ONE 1.0f
#define LPC_SCALING  1.f
#define SIG_SCALING  1.f
#define LSP_SCALING  1.f
#define GAMMA_SCALING 1.f
#define GAIN_SCALING 1.f
#define GAIN_SCALING_1 1.f


#define VERY_SMALL 1e-15f
#define VERY_LARGE32 1e15f
#define VERY_LARGE16 1e15f
#define Q15_ONE ((spx_word16_t)1.f)

#define QCONST16(x,bits) (x)
#define QCONST32(x,bits) (x)

#define NEG16(x) (-(x))
#define NEG32(x) (-(x))
#define EXTRACT16(x) (x)
#define EXTEND32(x) (x)
#define SHR16(a,shift) (a)
#define SHL16(a,shift) (a)
#define SHR32(a,shift) (a)
#define SHL32(a,shift) (a)
#define PSHR16(a,shift) (a)
#define PSHR32(a,shift) (a)
#define VSHR32(a,shift) (a)
#define SATURATE16(x,a) (x)
#define SATURATE32(x,a) (x)

#define PSHR(a,shift)       (a)
#define SHR(a,shift)       (a)
#define SHL(a,shift)       (a)
#define SATURATE(x,a) (x)

#define ADD16(a,b) ((a)+(b))
#define SUB16(a,b) ((a)-(b))
#define ADD32(a,b) ((a)+(b))
#define SUB32(a,b) ((a)-(b))
#define MULT16_16_16(a,b)     ((a)*(b))
#define MULT16_16(a,b)     ((spx_word32_t)(a)*(spx_word32_t)(b))
#define MAC16_16(c,a,b)     ((c)+(spx_word32_t)(a)*(spx_word32_t)(b))

#define MULT16_32_Q11(a,b)     ((a)*(b))
#define MULT16_32_Q13(a,b)     ((a)*(b))
#define MULT16_32_Q14(a,b)     ((a)*(b))
#define MULT16_32_Q15(a,b)     ((a)*(b))
#define MULT16_32_P15(a,b)     ((a)*(b))

#define MAC16_32_Q11(c,a,b)     ((c)+(a)*(b))
#define MAC16_32_Q15(c,a,b)     ((c)+(a)*(b))

#define MAC16_16_Q11(c,a,b)     ((c)+(a)*(b))
#define MAC16_16_Q13(c,a,b)     ((c)+(a)*(b))
#define MAC16_16_P13(c,a,b)     ((c)+(a)*(b))
#define MULT16_16_Q11_32(a,b)     ((a)*(b))
#define MULT16_16_Q13(a,b)     ((a)*(b))
#define MULT16_16_Q14(a,b)     ((a)*(b))
#define MULT16_16_Q15(a,b)     ((a)*(b))
#define MULT16_16_P15(a,b)     ((a)*(b))
#define MULT16_16_P13(a,b)     ((a)*(b))
#define MULT16_16_P14(a,b)     ((a)*(b))

#define DIV32_16(a,b)     (((spx_word32_t)(a))/(spx_word16_t)(b))
#define PDIV32_16(a,b)     (((spx_word32_t)(a))/(spx_word16_t)(b))
#define DIV32(a,b)     (((spx_word32_t)(a))/(spx_word32_t)(b))
#define PDIV32(a,b)     (((spx_word32_t)(a))/(spx_word32_t)(b))


#endif


#if defined (CONFIG_TI_C54X) || defined (CONFIG_TI_C55X)


#define BYTES_PER_CHAR 2 
#define BITS_PER_CHAR 16
#define LOG2_BITS_PER_CHAR 4

#else 

#define BYTES_PER_CHAR 1
#define BITS_PER_CHAR 8
#define LOG2_BITS_PER_CHAR 3

#endif



#ifdef FIXED_DEBUG
extern long long spx_mips;
#endif


#endif
