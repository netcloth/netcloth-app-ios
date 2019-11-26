#ifndef KEYTOOL_H
#define KEYTOOL_H
#include <string>
#include <array>
extern const uint32_t PRI_KEY_SIZE;
extern const uint32_t PUB_KEY_SIZE;
extern const uint32_t HASH_SIZE;
extern const uint32_t SIGN_SIZE;
extern const uint32_t AES_IV_SIZE;
extern const uint32_t AES_KEY_SIZE;

std::string CreateCustomRandom(int len);

std::string CreatePrivateKey();

std::string GetPublicKeyByPrivateKey(const std::string private_key_org);

std::string GetSignByPrivateKey(const uint8_t* buf, size_t length, const std::string pri_key);

std::string GetEcdhKey(const std::string& pub_key, const std::string& pri_key);

bool SignIsValidate(const uint8_t* buf, size_t length, const std::string& pub_key, const std::string& sign);

std::string CreateAesIVKey();

bool AesEncode(const std::string& key, const std::string& iv, const std::string& in, std::string& out);

bool AesDecode(const std::string& key, const std::string& iv, const std::string& in, std::string& out);

uint64_t GetHash(const std::string& str);
#endif
