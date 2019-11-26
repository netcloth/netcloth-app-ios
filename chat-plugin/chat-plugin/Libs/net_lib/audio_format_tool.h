#ifndef AUDIO_FORMAT_TOOL_H
#define AUDIO_FORMAT_TOOL_H

#include <string>
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
#endif
