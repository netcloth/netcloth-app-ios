#ifndef SECP256K1_ECDH_H
#define SECP256K1_ECDH_H

#include "secp256k1.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef int (*secp256k1_ecdh_hash_function)(
  unsigned char *output,
  const unsigned char *x,
  const unsigned char *y,
  void *data
);


SECP256K1_API extern const secp256k1_ecdh_hash_function secp256k1_ecdh_hash_function_sha256;


SECP256K1_API extern const secp256k1_ecdh_hash_function secp256k1_ecdh_hash_function_default;

SECP256K1_API SECP256K1_WARN_UNUSED_RESULT int secp256k1_ecdh(
  const secp256k1_context* ctx,
  unsigned char *output,
  const secp256k1_pubkey *pubkey,
  const unsigned char *privkey,
  secp256k1_ecdh_hash_function hashfp,
  void *data
) SECP256K1_ARG_NONNULL(1) SECP256K1_ARG_NONNULL(2) SECP256K1_ARG_NONNULL(3) SECP256K1_ARG_NONNULL(4);

#ifdef __cplusplus
}
#endif

#endif 
