int main()
{
    int t1 = 0, t2 = 1, nextTerm = 0;
    int n = 100;
    nextTerm = t1 + t2;
 
    while(nextTerm <= n)
    {
        t1 = t2;
        t2 = nextTerm;
        nextTerm = t1 + t2;
    }
    
    return 0;
}