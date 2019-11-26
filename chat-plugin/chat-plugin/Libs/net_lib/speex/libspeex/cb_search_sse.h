

#include <xmmintrin.h>

static inline void _spx_mm_getr_ps (__m128 U, float *__Z, float *__Y, float *__X, float *__W)
{
  union {
    float __a[4];
    __m128 __v;
  } __u;
  
  __u.__v = U;

  *__Z = __u.__a[0];
  *__Y = __u.__a[1];
  *__X = __u.__a[2];
  *__W = __u.__a[3];

}

#define OVERRIDE_COMPUTE_WEIGHTED_CODEBOOK
static void compute_weighted_codebook(const signed char *shape_cb, const spx_sig_t *_r, float *resp, __m128 *resp2, __m128 *E, int shape_cb_size, int subvect_size, char *stack)
{
   int i, j, k;
   __m128 resj, EE;
   VARDECL(__m128 *r);
   VARDECL(__m128 *shape);
   ALLOC(r, subvect_size, __m128);
   ALLOC(shape, subvect_size, __m128);
   for(j=0;j<subvect_size;j++)
      r[j] = _mm_load_ps1(_r+j);
   for (i=0;i<shape_cb_size;i+=4)
   {
      float *_res = resp+i*subvect_size;
      const signed char *_shape = shape_cb+i*subvect_size;
      EE = _mm_setzero_ps();
      for(j=0;j<subvect_size;j++)
      {
         shape[j] = _mm_setr_ps(0.03125*_shape[j], 0.03125*_shape[subvect_size+j], 0.03125*_shape[2*subvect_size+j], 0.03125*_shape[3*subvect_size+j]);
      }
      for(j=0;j<subvect_size;j++)
      {
         resj = _mm_setzero_ps();
         for (k=0;k<=j;k++)
            resj = _mm_add_ps(resj, _mm_mul_ps(shape[k],r[j-k]));
         _spx_mm_getr_ps(resj, _res+j, _res+subvect_size+j, _res+2*subvect_size+j, _res+3*subvect_size+j);
         *resp2++ = resj;
         EE = _mm_add_ps(EE, _mm_mul_ps(resj, resj));
      }
      E[i>>2] = EE;
   }
}
