#ifndef AUDIO_FORMAT_TOOL_H
#define AUDIO_FORMAT_TOOL_H

#include <string>
/* 目前支持的原始音频格式为
单声道（mono）
采样频率:11025
采样格式:PCM16

使用流程:
1、发送音频时的编码
AudioFormatTool audio_tool = AudioFormatTool(msg_version, audio_ori, false);
std::string for_send = audio_tool.GetEncodedString();

2接收音频时的解码
AudioFormatTool audio_tool = AudioFormatTool(msg_version, audio_encoded, true);
std::string for_play = audio_tool.GetPCMString();
*/
const uint32_t AFT_RATE = 11025;
class  AudioFormatTool{
public:
    AudioFormatTool(uint32_t version, const std::string& audio, bool encoded);
    double GetSec();
    std::string GetPCMString();
    std::string GetEncodedString();
private:
    std::string Encode(const std::string& audio, uint32_t version);
    std::string Decode(const std::string& audio, uint32_t version);
private:
    std::string audio_pcm_;
    std::string audio_encoded_;
};
#endif // AUDIO_FORMAT_TOOL_H
