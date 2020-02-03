#include "key_tool.h"
#include <assert.h>
#include <random>
#include <string.h>
#include "string_tools.h"
#include "blake2/blake2.h"
#include "aes/aes.h"
#include "secp256k1/secp256k1.h"
#include "secp256k1/secp256k1_ecdh.h"
const uint32_t PRI_KEY_SIZE = 32;
const uint32_t PUB_KEY_SIZE = PRI_KEY_SIZE*2+1;
const uint32_t HASH_SIZE = 32;
const uint32_t SIGN_SIZE = 64;
const uint32_t AES_IV_SIZE = AES_BLOCKSIZE;
const uint32_t AES_KEY_SIZE = AES256_KEYSIZE;

  
std::string CreateCustomRandom(int len)
{
    std::string rtn((size_t)(len+4), '\0');
    std::random_device rd;
    for(int i = 0; i < len; i += 4){
        if(i < len){
            *(uint32_t*)(rtn.data()+i) = rd();
        }
    }
    rtn.resize(len);
    return rtn;
}

std::string CreatePrivateKey()
{
    std::string rtn;
    rtn = CreateCustomRandom(32);
    return rtn;
}
std::string GetPublicKeyByPrivateKey(const std::string private_key){
    
    if (private_key.length() < PRI_KEY_SIZE) {
        return "";
    }

    std::string rtn;
      
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY|SECP256K1_CONTEXT_SIGN);
    assert(ctx != nullptr);
    std::string vseed = CreateCustomRandom(32);
    bool ret = secp256k1_context_randomize(ctx, (uint8_t*)vseed.data());
    assert(ret);
    secp256k1_pubkey pubkey;
    ret = secp256k1_ec_pubkey_create(ctx, &pubkey, (uint8_t*)private_key.data());
    assert(ret);
    rtn.resize(PUB_KEY_SIZE, 0);
    size_t clen = PUB_KEY_SIZE;
    secp256k1_ec_pubkey_serialize(ctx, (uint8_t*)rtn.data(), &clen, &pubkey,  SECP256K1_EC_UNCOMPRESSED);
      
    if (ctx) {
        secp256k1_context_destroy(ctx);
    }
    return rtn;
}

bool SigHasLowR(secp256k1_context *secp256k1_context_sign, const secp256k1_ecdsa_signature* sig)
{
    unsigned char compact_sig[64];
    secp256k1_ecdsa_signature_serialize_compact(secp256k1_context_sign, compact_sig, sig);

      
      
      
      
    return compact_sig[0] < 0x80;
}

void static inline WriteLE32(unsigned char* ptr, uint16_t x)
{
    uint32_t v = x;
    memcpy(ptr, (char*)&v, 4);
}
std::string GetSignByPrivateKey(const uint8_t* buf, size_t length, const std::string pri_key){
      
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY|SECP256K1_CONTEXT_SIGN);
    assert(ctx != nullptr);
    std::string vseed = CreateCustomRandom(32);
    bool ret = secp256k1_context_randomize(ctx, (uint8_t*)vseed.data());
    assert(ret);

    assert(length == HASH_SIZE);
    std::string rtn(SIGN_SIZE, '\0');
    rtn.resize(SIGN_SIZE);
    size_t nSigLen = SIGN_SIZE;
    unsigned char extra_entropy[32] = {0};
    secp256k1_ecdsa_signature sig;
    uint32_t counter = 0;
    ret = secp256k1_ecdsa_sign(ctx, &sig, buf, (uint8_t*)pri_key.data(), secp256k1_nonce_function_rfc6979, nullptr);

      
    /*while (ret && !SigHasLowR(ctx, &sig) ) {
        WriteLE32(extra_entropy, ++counter);
        ret = secp256k1_ecdsa_sign(ctx, &sig, buf, (uint8_t*)pri_key.data(), secp256k1_nonce_function_rfc6979, extra_entropy);
    }
    assert(ret);*/
    memcpy((void*)rtn.data(), &sig, SIGN_SIZE);

      
    if (ctx) {
        secp256k1_context_destroy(ctx);
    }

    return rtn;
}

bool SignIsValidate(const uint8_t* buf, size_t length, const std::string& pub_key, const std::string& sign){
    assert(length == HASH_SIZE);
    assert(sign.size() == SIGN_SIZE);

      
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY);
    assert(ctx != nullptr);
    std::string vseed = CreateCustomRandom(32);
    bool ret = secp256k1_context_randomize(ctx, (uint8_t*)vseed.data());
    assert(ret);

    secp256k1_pubkey pubkey;
    secp256k1_ec_pubkey_parse(ctx, &pubkey, (uint8_t*)pub_key.data(), PUB_KEY_SIZE);
      
    secp256k1_ecdsa_signature sig;
    memcpy(&sig, sign.data(), SIGN_SIZE);
      
    bool rtn = secp256k1_ecdsa_verify(ctx, &sig, buf, &pubkey)?true:false;


      
    if (ctx) {
        secp256k1_context_destroy(ctx);
    }
    return rtn;
      
}

std::string CreateAesIVKey()
{
    return CreateCustomRandom(AES_BLOCKSIZE);
}

bool AesEncode(const std::string& key, const std::string& iv, const std::string& in, std::string &out)
{
    std::string key_use = key;
      
    if(iv.size() != AES_BLOCKSIZE){
        return false;
    }
      
    if(key_use.size() != AES256_KEYSIZE){
        key_use.resize(AES256_KEYSIZE, 0);
    }
    out.resize((in.size()+AES_BLOCKSIZE) - (in.size()+AES_BLOCKSIZE)%AES_BLOCKSIZE, 0);
    AES256CBCEncrypt enc((uint8_t*)key_use.data(), (uint8_t*)iv.data(), true);
    int len = enc.Encrypt((uint8_t*)in.data(), in.size(), (uint8_t*)out.data());
    return len == out.size();
}

bool AesDecode(const std::string &key, const std::string &iv, const std::string &in, std::string &out)
{
    out.resize((in.size()+AES_BLOCKSIZE) - (in.size()+AES_BLOCKSIZE)%AES_BLOCKSIZE, 0);
    std::string key_use = key;
      
    if(iv.size() != AES_BLOCKSIZE){
        return false;
    }
      
    if(key_use.size() != AES256_KEYSIZE){
        key_use.resize(AES256_KEYSIZE, 0);
    }
    
    AES256CBCDecrypt enc((uint8_t*)key_use.data(), (uint8_t*)iv.data(), true);
    int len = enc.Decrypt((uint8_t*)in.data(), in.size(), (uint8_t*)out.data());
    out.resize(len);
    return true;
}

std::string GetEcdhKey(const std::string &pub_key, const std::string &pri_key)
{

    if(pub_key.size() != PUB_KEY_SIZE || pri_key.size() != PRI_KEY_SIZE){
        return std::string();
    }

      
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY|SECP256K1_CONTEXT_SIGN);
    assert(ctx != nullptr);
    std::string vseed = CreateCustomRandom(32);
    bool ret = secp256k1_context_randomize(ctx, (uint8_t*)vseed.data());
    assert(ret);

    std::string rtn((size_t)(AES_KEY_SIZE), '\0');
    secp256k1_pubkey pubkey;
    secp256k1_ec_pubkey_parse(ctx, &pubkey, (uint8_t*)pub_key.data(), PUB_KEY_SIZE);
    secp256k1_ecdh(ctx, (uint8_t*)rtn.data(), &pubkey, (uint8_t*)pri_key.data(),NULL, NULL);


      
    if (ctx) {
        secp256k1_context_destroy(ctx);
    }
    return rtn;
}


uint64_t GetHash(const std::string &str)
{
    std::string rtn(8, 0);
    blake2b_state hash_state;
    blake2b_init(&hash_state, 8);
    blake2b_update(&hash_state, str.data(), str.size());
    blake2b_final(&hash_state, (char*)rtn.data(), rtn.size());
    return *(uint64_t*)rtn.data();
}
