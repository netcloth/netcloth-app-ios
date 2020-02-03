#include "audio_format_tool.h"
#include "speex/speex.h"

AudioFormatTool::AudioFormatTool(uint32_t version, const std::string &audio, bool encoded){
    if(version == 0){
        audio_pcm_ = encoded?Decode(audio, version):audio;
        audio_encoded_ = encoded?audio:Encode(audio, version);
    }
}

double AudioFormatTool::GetSec(){
    return audio_pcm_.size()*1.0/2/AFT_RATE;
}

std::string AudioFormatTool::GetPCMString(){
    return audio_pcm_;
}

std::string AudioFormatTool::GetEncodedString(){
    return audio_encoded_;
}

std::string AudioFormatTool::Encode(const std::string &audio, uint32_t version){
    SpeexBits enc_bits;
    int enc_frame_size = 0;
    void *enc_state;
    std::string audio_in = audio;
      
    speex_bits_init(&enc_bits);
    enc_state = speex_encoder_init(&speex_nb_mode);
    int quality = 8;
    speex_encoder_ctl(enc_state, SPEEX_SET_QUALITY, &quality);
    speex_encoder_ctl(enc_state, SPEEX_GET_FRAME_SIZE, &enc_frame_size);

      
    std::string rtn;
    int frames_count = audio_in.size()/2/enc_frame_size+1;
    std::string for_fill(enc_frame_size*2, 0);
    audio_in+=for_fill;
    for(int i = 0; i < frames_count; i++) {
        speex_bits_reset(&enc_bits);
        speex_encode_int(enc_state, (int16_t*)audio_in.data()+i*enc_frame_size, &enc_bits);
        int count = speex_bits_nbytes(&enc_bits);
        std::string frame_buf;
        frame_buf.resize(count+1, 0);  
        (*(uint8_t*)frame_buf.data())=count;
        speex_bits_write(&enc_bits, (char *)frame_buf.data()+1, count+100);
        rtn += frame_buf;
    }
    return rtn;
}

std::string AudioFormatTool::Decode(const std::string &audio, uint32_t version)
{
    int dec_frame_size;
    SpeexBits dec_bits;
    void *dec_state;

      
    speex_bits_init(&dec_bits);
    dec_state = speex_decoder_init(&speex_nb_mode);
    speex_decoder_ctl(dec_state, SPEEX_GET_FRAME_SIZE, &dec_frame_size);

    std::string rtn;
    if(audio.size() > 1){
        int index = 0;
        while(1){
            if(index >= audio.size())break;
            uint8_t frame_size = *((uint8_t*)audio.data());
            index++;
            if(index+frame_size > audio.size())break;
            speex_bits_read_from(&dec_bits, audio.data()+index, frame_size);
            std::string frame_buf;
            frame_buf.resize(dec_frame_size*2, 0);
            speex_decode_int(dec_state, &dec_bits, (int16_t*)frame_buf.data());
            rtn += frame_buf;
            index+=frame_size;
        }
    }
    return rtn;
}
