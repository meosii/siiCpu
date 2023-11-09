int main ()
{
   int n[ 10 ];
   int i;
   int sum;
   int sum_1;
 
   for ( i = 0; i < 10; i++ )
   {
      n[ i ] = i << 2;
      sum = sum + n[i];
      sum_1 = sum_1 + sum + n[i];
   }
 
   int a;
   int b;
   int c;
   int d;
   int e;
   int f;
   int g;

   if (n[0] < 10) {
      a = 99 + n[0];
   } else {
      a = 4;
   }

   if (n[1] != 10) {
      b = 111 >> n[1];
   } else {
      b = 4;
   }

   if (n[2] > 10) {
      c = 4;
   } else {
      c = 222 ^ n[2];
   }

   if (n[3] == 12) {
      d = 333 & n[3];
   } else {
      d = 4;
   }

   if ((n[4] - 4) == 12) {
      d = 444 | n[4];
   } else {
      d = 4;
   }

   if (n[5] > -12) {
      e = 555;
   } else {
      e = 4;
   }

   if (n[6] >= 24) {
      f = 666;
   } else {
      f = 4;
   }

   if (sum == 180) {
      g = 999;
   } else {
      g = 4;
   }

   return 0;
}