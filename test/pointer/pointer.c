int main () {
    int age_1 = 8;
    int age_2 = 16;
    int age_3 = 17;
    int age_4;
    int age_5;
    int num_1 = 1;
    int a;
    int b;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int *address_1 = &age_1;
    int *address_2 = &age_2;
    int *address_3 = &age_3;
    int *address_4 = &age_4;
    int *address_5 = &age_5;
    *address_4 = 18;
    *address_5 = 20;
    if (*address_5 - *address_4 > *address_3 - *address_2) {
        a = *address_5 - *address_4;
    } else {
        a = *address_3 + *address_2;
    }
    while (*address_1 < 20) {
        b = age_1 + age_2;
        c = age_1 || age_2;
        d = age_1 ^ age_2;
        e = age_1 << 1;
        f = age_1 >> 1;
        g = age_1 << num_1;
        h = age_1 >> num_1;
        break;
    }
}