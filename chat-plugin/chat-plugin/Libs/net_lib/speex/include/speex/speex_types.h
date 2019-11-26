
#ifndef _SPEEX_TYPES_H
#define _SPEEX_TYPES_H

#if defined(_WIN32)

#  if defined(__CYGWIN__)
#    include <_G_config.h>
     typedef _G_int32_t spx_int32_t;
     typedef _G_uint32_t spx_uint32_t;
     typedef _G_int16_t spx_int16_t;
     typedef _G_uint16_t spx_uint16_t;
#  elif defined(__MINGW32__)
     typedef short spx_int16_t;
     typedef unsigned short spx_uint16_t;
     typedef int spx_int32_t;
     typedef unsigned int spx_uint32_t;
#  elif defined(__MWERKS__)
     typedef int spx_int32_t;
     typedef unsigned int spx_uint32_t;
     typedef short spx_int16_t;
     typedef unsigned short spx_uint16_t;
#  else
     
     typedef __int32 spx_int32_t;
     typedef unsigned __int32 spx_uint32_t;
     typedef __int16 spx_int16_t;
     typedef unsigned __int16 spx_uint16_t;
#  endif

#elif defined(__MACOS__)

#  include <sys/types.h>
   typedef SInt16 spx_int16_t;
   typedef UInt16 spx_uint16_t;
   typedef SInt32 spx_int32_t;
   typedef UInt32 spx_uint32_t;

#elif (defined(__APPLE__) && defined(__MACH__)) 

#  include <sys/types.h>
   typedef int16_t spx_int16_t;
   typedef u_int16_t spx_uint16_t;
   typedef int32_t spx_int32_t;
   typedef u_int32_t spx_uint32_t;

#elif defined(__BEOS__)

   
#  include <inttypes.h>
   typedef int16_t spx_int16_t;
   typedef u_int16_t spx_uint16_t;
   typedef int32_t spx_int32_t;
   typedef u_int32_t spx_uint32_t;

#elif defined (__EMX__)

   
   typedef short spx_int16_t;
   typedef unsigned short spx_uint16_t;
   typedef int spx_int32_t;
   typedef unsigned int spx_uint32_t;

#elif defined (DJGPP)

   
   typedef short spx_int16_t;
   typedef int spx_int32_t;
   typedef unsigned int spx_uint32_t;

#elif defined(R5900)

   
   typedef int spx_int32_t;
   typedef unsigned spx_uint32_t;
   typedef short spx_int16_t;

#elif defined(__SYMBIAN32__)

   
   typedef signed short spx_int16_t;
   typedef unsigned short spx_uint16_t;
   typedef signed int spx_int32_t;
   typedef unsigned int spx_uint32_t;

#elif defined(CONFIG_TI_C54X) || defined (CONFIG_TI_C55X)

   typedef short spx_int16_t;
   typedef unsigned short spx_uint16_t;
   typedef long spx_int32_t;
   typedef unsigned long spx_uint32_t;

#elif defined(CONFIG_TI_C6X)

   typedef short spx_int16_t;
   typedef unsigned short spx_uint16_t;
   typedef int spx_int32_t;
   typedef unsigned int spx_uint32_t;

#else
   #include <stdint.h>
   typedef int16_t spx_int16_t;
   typedef uint16_t spx_uint16_t;
   typedef int32_t spx_int32_t;
   typedef uint32_t spx_uint32_t;

#endif

#endif  
