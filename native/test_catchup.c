#define CATCHUP_TEST
#include "catchup.c"
#include <assert.h>
#include <stdio.h>
int main(void){
    unsigned char sub[0x698]={0},grid[0xd0]={0},m1[0xda0]={0},m2[0xda0]={0};
    ModuleEntry entries[3]={{m1,0,0},{NULL,0,0},{m2,0,0}};
    ModuleSet *set=(ModuleSet *)(grid+8);set->data=entries;set->num=3;set->capacity=3;
    set->bit_count=3;set->bit_capacity=128;set->num_free=1;set->inline_bits[0]=5;
    *(double *)(sub+0x168)=100;*(double *)(sub+0x1d8)=1;
    *(void **)(m1+0x620)=sub;*(void **)(m2+0x620)=sub;
    m1[0x977]=m2[0x977]=1;*(double *)(m1+0x988)=*(double *)(m2+0x988)=100;
    active=1;assert(!redundant(sub,grid,1));sub[0x330]=1;assert(redundant(sub,grid,1));
    *(double *)(m2+0x988)=80;assert(!redundant(sub,grid,1));
    *(double *)(m2+0x988)=99;assert(!redundant(sub,grid,1));
    *(double *)(m2+0x988)=99.5;assert(redundant(sub,grid,1));
    *(double *)(m2+0x988)=0;assert(!redundant(sub,grid,1));
    *(double *)(m2+0x988)=100;m2[0x977]=0;assert(!redundant(sub,grid,1));m2[0x977]=1;
    set->bit_count=5;assert(!redundant(sub,grid,1));set->bit_count=3;
    set->num_free=3;assert(!redundant(sub,grid,1));set->num_free=1;
    assert(!redundant(sub,grid,NAN));assert(!redundant(sub,grid,0));
    active=0;assert(!redundant(sub,grid,1));
    puts("catchup guard: normal tick, inactive, sparse grid, real debt, zero stamp, invalid state passed");
    return 0;
}
