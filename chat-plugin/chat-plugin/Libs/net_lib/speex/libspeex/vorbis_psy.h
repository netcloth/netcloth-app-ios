
#ifndef VORBIS_PSY_H
#define VORBIS_PSY_H

#ifdef VORBIS_PSYCHO

#include "smallft.h"
#define P_BANDS 17      
#define NOISE_COMPAND_LEVELS 40


#define todB(x)   ((x)>1e-13?log((x)*(x))*4.34294480f:-30)
#define fromdB(x) (exp((x)*.11512925f))  


#define toBARK(n)   (13.1f*atan(.00074f*(n))+2.24f*atan((n)*(n)*1.85e-8f)+1e-4f*(n))
#define fromBARK(z) (102.f*(z)-2.f*pow(z,2.f)+.4f*pow(z,3.f)+pow(1.46f,z)-1.f)


#define toOC(n)     (log(n)*1.442695f-5.965784f)
#define fromOC(o)   (exp(((o)+5.965784f)*.693147f))


typedef struct {

  float noisewindowlo;
  float noisewindowhi;
  int   noisewindowlomin;
  int   noisewindowhimin;
  int   noisewindowfixed;
  float noiseoff[P_BANDS];
  float noisecompand[NOISE_COMPAND_LEVELS];

} VorbisPsyInfo;



typedef struct {
  int n;
  int rate;
  struct drft_lookup lookup;
  VorbisPsyInfo *vi;

  float *window;
  float *noiseoffset;
  long  *bark;

} VorbisPsy;


VorbisPsy *vorbis_psy_init(int rate, int size);
void vorbis_psy_destroy(VorbisPsy *psy);
void compute_curve(VorbisPsy *psy, float *audio, float *curve);
void curve_to_lpc(VorbisPsy *psy, float *curve, float *awk1, float *awk2, int ord);

#endif
#endif
