#ifndef MAIN_H
#define MAIN_H

#include <stdint.h>

#ifdef __cplusplus
#define MAIN_EXTERN_C extern "C"
#else
#define MAIN_EXTERN_C
#endif

#if defined(_WIN32)
#define MAIN_EXPORT MAIN_EXTERN_C __declspec(dllimport)
#else
#define MAIN_EXPORT MAIN_EXTERN_C __attribute__((visibility ("default")))
#endif

MAIN_EXPORT int32_t main(int32_t c_argc, uint8_t * * c_argv, uint8_t * * c_envp);

#endif
