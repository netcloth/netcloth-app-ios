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

/**
 * @brief 创建一个长度为len的随机数
 * @param len 随机数的长度(byte)
 * @return 随机数
 */
std::string CreateCustomRandom(int len);

/**
 * @brief 创建一个私钥
 * @return 私钥（二进制）
 */
std::string CreatePrivateKey();

/**
 * @brief 通过私钥计算得到公钥
 * @param private_key_org 私钥（二进制）
 * @return 公钥（二进制）
 */
std::string GetPublicKeyByPrivateKey(const std::string private_key_org);

/**
 * @brief 使用私钥对一段内存数据进行签名
 * @param buf 内存的地址
 * @param 内存的长度
 * @return 随机数
 */
std::string GetSignByPrivateKey(const uint8_t* buf, size_t length, const std::string pri_key);

/**
 * @brief 获取只有双方知道的共享密码
 * @param pub_key 对方公钥(二进制)
 * @param pri_key 己方私钥(二进制)
 * @return 共享秘钥(二进制)
 */
std::string GetEcdhKey(const std::string& pub_key, const std::string& pri_key);

/**
 * @brief 通过公钥判断签名是否正确
 * @param buf 所签名的数据地址
 * @param length 所签名的数据的长度 
 * @param pub_key 需要验证的签名的公钥（二进制）
 * @param sign 需要验证的签名（二进制）
 * @return 签名是否正确
 */
bool SignIsValidate(const uint8_t* buf, size_t length, const std::string& pub_key, const std::string& sign);

/**
 * @brief 创建一个AES的IV向量
 * @return IV向量（二进制）
 */
std::string CreateAesIVKey();

/**
 * @brief 使用AES进行加密
 * @param key 加密密码（二进制）
 * @param iv AES的IV向量（二进制） 
 * @param in 要进行加密的数据（二进制）
 * @param[out] out 加密之后的数据（二进制）
 * @return 加密是否成功
 */
bool AesEncode(const std::string& key, const std::string& iv, const std::string& in, std::string& out);

/**
 * @brief 使用AES进行解密
 * @param key 解密密码（二进制）
 * @param iv AES的IV向量（二进制） 
 * @param in 要进行解密的数据（二进制）
 * @param[out] out 解密之后的数据（二进制）
 * @return 解密是否成功（正常用用返回成功，即使密码错误也会解出一段乱码）
 */
bool AesDecode(const std::string& key, const std::string& iv, const std::string& in, std::string& out);

uint64_t GetHash(const std::string& str);
#endif // KEYTOOL_H
