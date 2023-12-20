//#include"stdio.h"
int main()
{
    unsigned int t1 = 0, t2 = 1, nextTerm = 0;
    unsigned int n = 30000;
    nextTerm = t1 + t2;
 
    while(nextTerm <= n)
    {
        t1 = t2;
        t2 = nextTerm;
        nextTerm = t1 + t2;
    }

//    unsigned int nextTerm_0 = (nextTerm<<28)>>28;
//    unsigned int nextTerm_1 = (nextTerm<<24)>>28;
//    unsigned int nextTerm_2 = (nextTerm<<20)>>28;
//    unsigned int nextTerm_3 = (nextTerm<<16)>>28;
//    unsigned int nextTerm_4 = (nextTerm<<12)>>28;
//    unsigned int nextTerm_5 = (nextTerm<<8)>>28;
//    unsigned int nextTerm_6 = (nextTerm<<4)>>28;
//    unsigned int nextTerm_7 = nextTerm>>28;
//
//    int *hex0 = &nextTerm_0;
//    int *hex1 = &nextTerm_1;
//    int *hex2 = &nextTerm_2;
//    int *hex3 = &nextTerm_3;
//    int *hex4 = &nextTerm_4;
//    int *hex5 = &nextTerm_5;
//    int *hex6 = &nextTerm_6;
//    int *hex7 = &nextTerm_7;
//
//    hex0 = (int*) 0x40000000;
//    hex1 = (int*) 0x40000004;
//    hex2 = (int*) 0x40000008;
//    hex3 = (int*) 0x4000000c;
//    hex4 = (int*) 0x40000010;
//    hex5 = (int*) 0x40000014;
//    hex6 = (int*) 0x40000018;
//    hex7 = (int*) 0x4000001c;

//    printf("%hx\n",nextTerm);
//    printf("%hx\n",nextTerm_0);
//    printf("%hx\n",nextTerm_1);
//    printf("%hx\n",nextTerm_2);
//    printf("%hx\n",nextTerm_3);
//    printf("%hx\n",nextTerm_4);
//    printf("%hx\n",nextTerm_5);
//    printf("%hx\n",nextTerm_6);
//    printf("%hx\n",nextTerm_7);

    return 0;
}