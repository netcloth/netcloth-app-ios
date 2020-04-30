/**********************************************************************
 * Copyright (c) 2014 Pieter Wuille                                   *
 * Distributed under the MIT software license, see the accompanying   *
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.*
 **********************************************************************/

#ifndef SECP256K1_BENCH_H
#define SECP256K1_BENCH_H

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#ifdef WIN32
#include <windows.h>
#else
#include <sys/time.h>
#endif
#ifdef WIN32
inline int gettimeofday(struct timeval *tp, void *tzp)
{
  time_t clock;
  struct tm tm;
  SYSTEMTIME wtm;
  GetLocalTime(&wtm);
  tm.tm_year   = wtm.wYear - 1900;
  tm.tm_mon   = wtm.wMonth - 1;
  tm.tm_mday   = wtm.wDay;
  tm.tm_hour   = wtm.wHour;
  tm.tm_min   = wtm.wMinute;
  tm.tm_sec   = wtm.wSecond;
  tm. tm_isdst  = -1;
  clock = mktime(&tm);
  tp->tv_sec = clock;
  tp->tv_usec = wtm.wMilliseconds * 1000;
  return (0);
}
#endif
static double gettimedouble(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_usec * 0.000001 + tv.tv_sec;
}

inline void print_number(double x) {
    double y = x;
    int c = 0;
    if (y < 0.0) {
        y = -y;
    }
    while (y > 0 && y < 100.0) {
        y *= 10.0;
        c++;
    }
    printf("%.*f", c, x);
}

inline void run_benchmark(char *name, void (*benchmark)(void*), void (*setup)(void*), void (*teardown)(void*), void* data, int count, int iter) {
    int i;
    double min = HUGE_VAL;
    double sum = 0.0;
    double max = 0.0;
    for (i = 0; i < count; i++) {
        double begin, total;
        if (setup != NULL) {
            setup(data);
        }
        begin = gettimedouble();
        benchmark(data);
        total = gettimedouble() - begin;
        if (teardown != NULL) {
            teardown(data);
        }
        if (total < min) {
            min = total;
        }
        if (total > max) {
            max = total;
        }
        sum += total;
    }
    printf("%s: min ", name);
    print_number(min * 1000000.0 / iter);
    printf("us / avg ");
    print_number((sum / count) * 1000000.0 / iter);
    printf("us / max ");
    print_number(max * 1000000.0 / iter);
    printf("us\n");
}

inline int have_flag(int argc, char** argv, char *flag) {
    char** argm = argv + argc;
    argv++;
    if (argv == argm) {
        return 1;
    }
    while (argv != NULL && argv != argm) {
        if (strcmp(*argv, flag) == 0) {
            return 1;
        }
        argv++;
    }
    return 0;
}

#endif /* SECP256K1_BENCH_H */
