
#ifndef OS_SUPPORT_H
#define OS_SUPPORT_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#ifdef OS_SUPPORT_CUSTOM
#include "os_support_custom.h"
#endif

#ifndef OVERRIDE_SPEEX_ALLOC
static inline void *speex_alloc (int size)
{
   return calloc(size,1);
}
#endif


#ifndef OVERRIDE_SPEEX_ALLOC_SCRATCH
static inline void *speex_alloc_scratch (int size)
{
   
   return calloc(size,1);
}
#endif


#ifndef OVERRIDE_SPEEX_REALLOC
static inline void *speex_realloc (void *ptr, int size)
{
   return realloc(ptr, size);
}
#endif


#ifndef OVERRIDE_SPEEX_FREE
static inline void speex_free (void *ptr)
{
   free(ptr);
}
#endif


#ifndef OVERRIDE_SPEEX_FREE_SCRATCH
static inline void speex_free_scratch (void *ptr)
{
   free(ptr);
}
#endif


#ifndef OVERRIDE_SPEEX_COPY
#define SPEEX_COPY(dst, src, n) (memcpy((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src)) ))
#endif

#ifndef OVERRIDE_SPEEX_MOVE
#define SPEEX_MOVE(dst, src, n) (memmove((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src)) ))
#endif


#ifndef OVERRIDE_SPEEX_MEMSET
#define SPEEX_MEMSET(dst, c, n) (memset((dst), (c), (n)*sizeof(*(dst))))
#endif


#ifndef OVERRIDE_SPEEX_FATAL
static inline void _speex_fatal(const char *str, const char *file, int line)
{
   fprintf (stderr, "Fatal (internal) error in %s, line %d: %s\n", file, line, str);
   exit(1);
}
#endif

#ifndef OVERRIDE_SPEEX_WARNING
static inline void speex_warning(const char *str)
{
#ifndef DISABLE_WARNINGS
   fprintf (stderr, "warning: %s\n", str);
#endif
}
#endif

#ifndef OVERRIDE_SPEEX_WARNING_INT
static inline void speex_warning_int(const char *str, int val)
{
#ifndef DISABLE_WARNINGS
   fprintf (stderr, "warning: %s %d\n", str, val);
#endif
}
#endif

#ifndef OVERRIDE_SPEEX_NOTIFY
static inline void speex_notify(const char *str)
{
#ifndef DISABLE_NOTIFICATIONS
   fprintf (stderr, "notification: %s\n", str);
#endif
}
#endif

#ifndef OVERRIDE_SPEEX_PUTC

static inline void _speex_putc(int ch, void *file)
{
   FILE *f = (FILE *)file;
   fprintf(f, "%c", ch);
}
#endif

#define speex_fatal(str) _speex_fatal(str, __FILE__, __LINE__);
#define speex_assert(cond) {if (!(cond)) {speex_fatal("assertion failed: " #cond);}}

#ifndef RELEASE
static inline void print_vec(float *vec, int len, char *name)
{
   int i;
   printf ("%s ", name);
   for (i=0;i<len;i++)
      printf (" %f", vec[i]);
   printf ("\n");
}
#endif

#endif

