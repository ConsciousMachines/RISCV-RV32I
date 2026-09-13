#define ARR_BASE  0x1000
#define ARR_COUNT 8

int main(void) 
{
    volatile unsigned int *arr = (unsigned int *)ARR_BASE;

    // unsorted data
    arr[0] = 42;
    arr[1] = 7;
    arr[2] = 19;
    arr[3] = 3;
    arr[4] = 88;
    arr[5] = 1;
    arr[6] = 56;
    arr[7] = 23;

    for (int i = 0; i < ARR_COUNT - 1; i++)
    {
        for (int j = 0; j < ARR_COUNT - 1 - i; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                unsigned int tmp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
            }
        }
    }

    while (1) {}

    return 0;
}
