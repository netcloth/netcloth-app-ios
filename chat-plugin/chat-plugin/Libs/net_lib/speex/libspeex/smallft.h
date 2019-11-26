
#ifndef _V_SMFT_H_
#define _V_SMFT_H_


#ifdef __cplusplus
extern "C" {
#endif


struct drft_lookup{
  int n;
  float *trigcache;
  int *splitcache;
};

extern void spx_drft_forward(struct drft_lookup *l,float *data);
extern void spx_drft_backward(struct drft_lookup *l,float *data);
extern void spx_drft_init(struct drft_lookup *l,int n);
extern void spx_drft_clear(struct drft_lookup *l);

#ifdef __cplusplus
}
#endif

#endif
