#include <stdio.h>

__global__ void add(int *a, int *b, int *c, int num) {
    int i = threadIdx.x;
    // int nums = 10;
    // __shared__ int sh[nums];
    // __shared__ int* sh = new int[nums];
    // 动态分配共享内存
    extern __shared__ int sh[];
    int *x = (int *)sh;
    
    if (i < num) {
	x[i] = a[i] + b[i];
        c[i] = x[i];
    }
}

int main(int argc, char* argv[]) {

    int num = 10;
    int a[num], b[num], c[num];
    int *a_gpu, *b_gpu, *c_gpu;

    for (int i = 0; i < num; i++) {
        a[i] = i;
	b[i] = i*i;
    }

    cudaMalloc((void**)&a_gpu, num*sizeof(int));
    cudaMalloc((void**)&b_gpu, num*sizeof(int));
    cudaMalloc((void**)&c_gpu, num*sizeof(int));

    // copy data
    cudaMemcpy(a_gpu, a, num*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(b_gpu, b, num*sizeof(int), cudaMemcpyHostToDevice);

    // do
    add<<<1, num, num>>>(a_gpu, b_gpu, c_gpu, num); // <<<>>>第三个参数是共享内存大小

    // get data
    cudaMemcpy(c, c_gpu, num*sizeof(int), cudaMemcpyDeviceToHost);

    // visualization
    for (int i=0; i < num; i++) {
        printf("%d + %d = %d\n", a[i], b[i], c[i]);
    }

    return 0;
}
