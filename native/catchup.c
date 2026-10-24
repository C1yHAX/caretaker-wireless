/* Caretaker Wireless 1.0.0 -- resource grid catch-up guard.
 * Voyage Steam 0.10.0.653173 only. No executable file is modified.
 * Native grid routing receives the global catch-up delta even when all of its
 * modules have already simulated that interval. Omit only those redundant grid
 * passes; grids containing a module with real simulation debt retain native code.
 */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <bcrypt.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
#include "third_party/minhook/include/MinHook.h"

typedef struct {
    void *data;
    int32_t num, capacity;
    uint32_t inline_bits[4];
    uint32_t *heap_bits;
    int32_t bit_count, bit_capacity, first_free, num_free;
    int32_t inline_hash, pad;
    void *hash;
    int32_t hash_size, pad2;
} ModuleSet;
typedef struct { unsigned char *module; int32_t next, index; } ModuleEntry;
_Static_assert(sizeof(ModuleSet)==0x50,"TSet layout");
_Static_assert(sizeof(ModuleEntry)==0x10,"TSet element layout");
typedef void (*GridFn)(unsigned char *,unsigned char *,float);
static GridFn original_route,original_balance;
static volatile LONG active=0;
static volatile LONG64 skipped=0, passed_debt=0;
static bool initialized=false;

static bool redundant(unsigned char *sub,unsigned char *grid,float dt) {
    if (!InterlockedCompareExchange(&active,0,0) || !sub || !grid || !sub[0x330]) return false;
    const double now=*(double *)(sub+0x168);
    const double step=*(double *)(sub+0x1d8);
    if (!isfinite(now)||!isfinite(step)||step<=0||!isfinite(dt)||dt<=0) return false;
    const ModuleSet *s=(const ModuleSet *)(grid+8);
    if (s->num<=0||s->num>65536||s->capacity<s->num||!s->data||
        s->bit_count!=s->num||s->bit_capacity<s->num||s->num_free<0||s->num_free>=s->num||
        (s->bit_count>128&&!s->heap_bits)) return false;
    const uint32_t *bits=s->heap_bits?s->heap_bits:s->inline_bits;
    const ModuleEntry *entries=s->data;
    bool found=false;
    for(int32_t i=0;i<s->num;++i) {
        if(!(bits[i>>5]&(1u<<(i&31)))) continue;
        const unsigned char *m=entries[i].module;
        if(!m||*(void **)(m+0x620)!=sub||!m[0x977]) return false;
        const double last=*(const double *)(m+0x988);
        if(!isfinite(last)||last<=0) return false;
        // Match the game's per-module catch-up eligibility, including epsilon.
        if(last+step<=now+(double)0.0001f) { InterlockedIncrement64(&passed_debt);return false; }
        found=true;
    }
    return found;
}
static void route_hook(unsigned char *s,unsigned char *g,float dt) {
    if(redundant(s,g,dt)) {InterlockedIncrement64(&skipped);return;}
    original_route(s,g,dt);
}
static void balance_hook(unsigned char *s,unsigned char *g,float dt) {
    if(redundant(s,g,dt)) {InterlockedIncrement64(&skipped);return;}
    original_balance(s,g,dt);
}

#ifndef CATCHUP_TEST
#include "verify_image.h"
static bool initialize(void) {
    if(initialized) return true;
    if(!supported_executable()) return false;
    unsigned char *b=(unsigned char *)GetModuleHandleW(NULL);
    void *route=b+0x56ab2c0,*balance=b+0x56aca40;
    const unsigned char route_sig[]={0x4c,0x8b,0xdc,0x55,0x56,0x57,0x41,0x56,0x49,0x8d,0x6b,0xa1,0x48,0x81,0xec,0xc8};
    const unsigned char balance_sig[]={0x48,0x8b,0xc4,0x48,0x89,0x50,0x10,0x48,0x89,0x48,0x08,0x55,0x48,0x8d,0x68,0xa8};
    if(memcmp(route,route_sig,16)||memcmp(balance,balance_sig,16)) return false;
    HMODULE self;
    if(!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS|GET_MODULE_HANDLE_EX_FLAG_PIN,
       (LPCWSTR)(uintptr_t)&initialize,&self)) return false;
    if(MH_Initialize()!=MH_OK) return false;
    if(MH_CreateHook(route,(void *)&route_hook,(void **)&original_route)!=MH_OK)return false;
    if(MH_CreateHook(balance,(void *)&balance_hook,(void **)&original_balance)!=MH_OK){MH_RemoveHook(route);return false;}
    if(MH_EnableHook(balance)!=MH_OK){MH_RemoveHook(route);MH_RemoveHook(balance);return false;}
    if(MH_EnableHook(route)!=MH_OK){MH_DisableHook(balance);MH_RemoveHook(route);MH_RemoveHook(balance);return false;}
    initialized=true;return true;
}
/* Called by package.loadlib with exactly one Lua argument, true. Returning one
 * yields that existing argument, zero yields nil; no foreign Lua runtime/API. */
__declspec(dllexport) int caretaker_catchup_enable(void *l){(void)l;if(!initialize())return 0;InterlockedExchange(&active,1);return 1;}
__declspec(dllexport) int caretaker_catchup_disable(void *l){(void)l;InterlockedExchange(&active,0);return 1;}
__declspec(dllexport) int caretaker_catchup_status(void *l){(void)l;return InterlockedCompareExchange(&active,0,0)?1:0;}
__declspec(dllexport) int caretaker_catchup_skipped(void *l){(void)l;return InterlockedCompareExchange64(&skipped,0,0)>0?1:0;}
__declspec(dllexport) int caretaker_catchup_debt(void *l){(void)l;return InterlockedCompareExchange64(&passed_debt,0,0)>0?1:0;}
BOOL WINAPI DllMain(HINSTANCE i,DWORD r,LPVOID p){(void)i;(void)r;(void)p;return TRUE;}
#endif
