#ifndef STRING_TOOLS_H
#define STRING_TOOLS_H

#include <string>
#include <sstream>
/**
 * @brief 将二进制转换为hex字符类型
 * @param bytes 二进制的数据
 * @return 返回hex字符类型数据
 */
std::string inline Byte2HexAsc(const std::string& bytes){
    std::string out;
    std::ostringstream o_stream;
    for(uint8_t item:bytes){
        o_stream.width(2);
        o_stream.fill('0');
        o_stream<<std::hex<<(uint32_t)item;
    }
    o_stream.flush();
    return o_stream.str();
}

/**
 * @brief 将hex字符类型转换为二进制
 * @param hex hex字符类型数据
 * @return 返回二进制的数据
 */
std::string inline HexAsc2ByteString(const std::string& hex){
    std::string rtn;
    for(size_t i = 0; i < hex.length(); i+=2){
        rtn += (char)std::strtol(hex.substr(i, 2).c_str(), nullptr, 16);
    }
    return rtn;
}
#endif // STRING_TOOLS_H
