


#ifndef VBR_H
#define VBR_H

#include "arch.h"

#define VBR_MEMORY_SIZE 5

extern const float vbr_nb_thresh[9][11];
extern const float vbr_hb_thresh[5][11];
extern const float vbr_uhb_thresh[2][11];


typedef struct VBRState {
   float average_energy;
   float last_energy;
   float last_log_energy[VBR_MEMORY_SIZE];
   float accum_sum;
   float last_pitch_coef;
   float soft_pitch;
   float last_quality;
   float noise_level;
   float noise_accum;
   float noise_accum_count;
   int   consec_noise;
} VBRState;

void vbr_init(VBRState *vbr);

float vbr_analysis(VBRState *vbr, spx_word16_t *sig, int len, int pitch, float pitch_coef);

void vbr_destroy(VBRState *vbr);

#endif
