
#ifndef SECP256K1_HASH_H
#define SECP256K1_HASH_H

#include <stdlib.h>
#include <stdint.h>

typedef struct {
    uint32_t s[8];
    uint32_t buf[16]; 
    size_t bytes;
} secp256k1_sha256;

static void secp256k1_sha256_initialize(secp256k1_sha256 *hash);
static void secp256k1_sha256_write(secp256k1_sha256 *hash, const unsigned char *data, size_t size);
static void secp256k1_sha256_finalize(secp256k1_sha256 *hash, unsigned char *out32);

typedef struct {
    secp256k1_sha256 inner, outer;
} secp256k1_hmac_sha256;

static void secp256k1_hmac_sha256_initialize(secp256k1_hmac_sha256 *hash, const unsigned char *key, size_t size);
static void secp256k1_hmac_sha256_write(secp256k1_hmac_sha256 *hash, const unsigned char *data, size_t size);
static void secp256k1_hmac_sha256_finalize(secp256k1_hmac_sha256 *hash, unsigned char *out32);

typedef struct {
    unsigned char v[32];
    unsigned char k[32];
    int retry;
} secp256k1_rfc6979_hmac_sha256;

static void secp256k1_rfc6979_hmac_sha256_initialize(secp256k1_rfc6979_hmac_sha256 *rng, const unsigned char *key, size_t keylen);
static void secp256k1_rfc6979_hmac_sha256_generate(secp256k1_rfc6979_hmac_sha256 *rng, unsigned char *out, size_t outlen);
static void secp256k1_rfc6979_hmac_sha256_finalize(secp256k1_rfc6979_hmac_sha256 *rng);

#endif 
