#ifndef _SHA512_111H_
#define _SHA512_111H_

#include <stdint.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C"{
#endif

typedef struct
{
    uint64_t    length;
    uint64_t    state[8];
    uint32_t    curlen;
    uint8_t     buf[128];
} Sha512Context;

#define SHA512_HASH_SIZE           ( 512 / 8 )

typedef struct
{
    uint8_t      bytes [SHA512_HASH_SIZE];
} SHA512_HASH;










void
    Sha512Initialise
    (
        Sha512Context*      Context         
    );







void
    Sha512Update
    (
        Sha512Context*      Context,        
        void const*         Buffer,         
        uint32_t            BufferSize      
    );







void
    Sha512Finalise
    (
        Sha512Context*      Context,        
        SHA512_HASH*        Digest          
    );
#ifdef __cplusplus
}
#endif
#endif
