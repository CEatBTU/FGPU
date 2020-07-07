#include "kernel_descriptor.hpp"

#define PRINT_ERRORS  0
extern unsigned *code; // binary storde in code.c as an array
extern unsigned *code_hard_float; // binary storde in code_hard_float.c as an array

template<typename T>
kernel<T>::kernel(unsigned max_size, bool hard_float)
{
  param1 = new T[max_size];
  target_fgpu = new T[max_size];
  target_arm = new T[max_size];
  twiddles = new T[max_size];
  // param1= (float complex*) 0x10000000;
  // twiddles=  (float complex*)0x14000000;
  // target_fgpu=  (float complex*)0x18000000;
  // target_arm=  (float complex*)0x1C000000;
  lram_ptr = (unsigned*) FGPU_BASEADDR;
  use_hard_float = hard_float;
}
template<typename T>
kernel<T>::~kernel() 
{
  delete[] param1;
  delete[] target_arm;
  delete[] target_fgpu;
  delete[] twiddles;
}
template<typename T>
void kernel<T>::download_code()
{
  volatile unsigned *cram_ptr = (unsigned *)(FGPU_BASEADDR+ 0x4000);
  unsigned int size = FFT_LEN;
  unsigned *code_ptr = code;
  if (typeid(T) == typeid(float complex)) {
    if(use_hard_float) {
      start_addr = BUTTERFLY_HARD_FLOAT_POS;
      size = FFT_HARD_FLOAT_LEN;
      code_ptr = code_hard_float;
    } else {
      start_addr = BUTTERFLY_POS;
    }
  }
  else
    assert(0 && "unsupported type");
  for(unsigned i = 0; i < size; i++){
    cram_ptr[i] = code_ptr[i];
  }
}
template<typename T>
void kernel<T>::download_descriptor()
{
  int i;
  for(i = 0; i < 32; i++)
    lram_ptr[i] = 0;
  lram_ptr[0] = ((nWF_WG-1) << 28) | (0 << 14) | (start_addr);
  lram_ptr[1] = size0;
  lram_ptr[2] = size1;
  lram_ptr[3] = size2;
  lram_ptr[4] = offset0;
  lram_ptr[5] = offset1;
  lram_ptr[6] = offset2;
  lram_ptr[7] = ((nDim-1) << 30) | (wg_size2 << 20) | (wg_size1 << 10) | (wg_size0);
  lram_ptr[8] = n_wg0-1;
  lram_ptr[9] = n_wg1-1;
  lram_ptr[10] = n_wg2-1;
  lram_ptr[11] = (nParams << 28) | wg_size;
  lram_ptr[16] = (unsigned) target_fgpu;
  lram_ptr[17] = (unsigned) stageIndx;
  lram_ptr[18] = (unsigned) twiddles;

}
template<typename T>
void kernel<T>::compute_descriptor()
{
  assert(wg_size0 > 0 && wg_size0 <= 512);
  assert(size0 % wg_size0 == 0);
  size = size0;
  wg_size = wg_size0;
  n_wg0 = size0 / wg_size0;
  if(nDim > 1)
  {
    assert(wg_size1 > 0 && wg_size1 <= 512);
    assert(size1 % wg_size1 == 0);
    size = size0 * size1;
    wg_size = wg_size0 * wg_size1;
    n_wg1 = size1 / wg_size1;
  }
  else
  {
    wg_size1 = n_wg1 = size1 = 0;
  }
  if(nDim > 2)
  {
    assert(wg_size2 > 0 && wg_size2 <= 512);
    assert(size2 % wg_size2 == 0);
    size = size0 * size1 * size2;
    wg_size = wg_size0 * wg_size1 * wg_size2;
    n_wg2 = size2 / wg_size2;
  }
  else
  {
    wg_size2 = n_wg2 = size2 = 0;
  }
  assert(wg_size <= 512);
  nWF_WG = wg_size / 64;
  if(wg_size % 64 != 0)
    nWF_WG++;
}
template<typename T>
void kernel<T>::prepare_descriptor(unsigned int Size)
{
  wg_size0 = 64;
  problemSize = Size;
  offset0 = 0;
  nDim = 1;
  size0 = Size/2;
  nStages = log2_int(problemSize);
  stageIndx = 0;
  dataSize = sizeof(T) * problemSize;

  if(size0 < 64 || wg_size0 > size0)
    wg_size0 = size0;

  compute_descriptor();

  offset0 = offset1 = offset2 = 0;
  nParams = 3; // number of parameters
}
template<typename T>
unsigned kernel<T>::get_problemSize() 
{
  return problemSize;
}
template<typename T>
void kernel<T>::initialize_memory()
{
  unsigned i;
  T *param_ptr = (T*) param1;
  T *target_fgpu_ptr = (T*) target_fgpu;
  T *target_arm_ptr = (T*) target_arm;
  for(i = 0; i < problemSize; i++) 
  {
    target_fgpu_ptr[i] = target_arm_ptr[i] = param_ptr[i] = (i%4) + 0i;
    float tmpf = 2*(float)i*M_PI/(float)problemSize;
    twiddles[i] = cosf(tmpf) - sinf(tmpf)*1i;
  }
  Xil_DCacheFlush(); // flush data to global memory
}
void bitReverse(float complex *src, unsigned len, int nStages)
{
  unsigned i;
  float complex *dst = &src[len];
  for(i = 0; i < len; i++)
  {
    unsigned j = i;
    j = (j & 0x55555555) << 1 | (j & 0xAAAAAAAA) >> 1;	
    j = (j & 0x33333333) << 2 | (j & 0xCCCCCCCC) >> 2;	
    j = (j & 0x0F0F0F0F) << 4 | (j & 0xF0F0F0F0) >> 4;	
    j = (j & 0x00FF00FF) << 8 | (j & 0xFF00FF00) >> 8;	
    j = (j & 0x0000FFFF) << 16 | (j & 0xFFFF0000) >> 16;
    j >>= (32-nStages);
    dst[j] = src[i];
  }
  for(i = 0; i < len; i++)
    src[i] = dst[i];
}
void FFT(unsigned problemSize, float complex *array, float complex *twiddles)
{
  unsigned i, iter;
  unsigned nStages = log2_int(problemSize);
  unsigned pairDistance, blockWidth, nGroups, groupOffset;
  unsigned leftIndx, rightIndx;
  float complex a, b, w;
  for(iter = 0; iter < nStages; iter++)
  {
    pairDistance = 1 << iter;
    blockWidth = 2 * pairDistance;
    nGroups = problemSize >> (iter+1);
    for(i = 0; i < problemSize/2; i++)
    {
      groupOffset = i & (pairDistance-1);	

      leftIndx = (i >> iter)*(blockWidth) + groupOffset;	
      rightIndx = leftIndx + pairDistance;	

      a = array[leftIndx];	
      b = array[rightIndx];	
      w = twiddles[nGroups*groupOffset];

      array[leftIndx] = a + w*b;
      array[rightIndx] = a - w*b;
    }
  }
}
template<typename T>
unsigned kernel<T>::compute_on_ARM(unsigned int n_runs)
{
  unsigned exec_time = 0;
  unsigned runs = 0;

  XTime tStart, tEnd;
  while(runs < n_runs)
  {
    initialize_memory();
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("input[%d]= %F + %Fj \n\r", i, creal(target_arm[i]), cimag(target_arm[i]));
    // }
    bitReverse(target_arm, problemSize, nStages);
    // printf("After bitReverse:\n");
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("input[%d]= %F + %Fj \n\r", i, creal(target_arm[i]), cimag(target_arm[i]));
    // }
    Xil_DCacheFlush();
    Xil_DCacheInvalidate();
    
    XTime_GetTime(&tStart);
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("twiddles[%d]= %F + %Fj \n\r", i, creal(twiddles[i]), cimag(twiddles[i]));
    // }
    FFT(problemSize, target_arm, twiddles);
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("output[%d]= %F + %Fj \n\r", i, creal(target_arm[i]), cimag(target_arm[i]));
    // }
    // flush the results to the global memory 
    Xil_DCacheFlushRange((unsigned)target_arm, dataSize);
    XTime_GetTime(&tEnd);

    exec_time += elapsed_time_us(tStart, tEnd);
    xil_printf(ANSI_COLOR_RED "." ANSI_COLOR_RESET);
    fflush(stdout);
    runs++;
    if(exec_time > 1000000*MAX_MES_TIME_S)
      break;
  }
  return exec_time/runs;
}
template<typename T>
void kernel<T>::check_FGPU_results()
{
  unsigned int i, nErrors = 0;
  Xil_DCacheInvalidate();
  // xil_printf("problemSize = %d\n\r", problemSize);
  // for(unsigned i = 0; i < problemSize; i++) {
  //   printf("target_arm[%d]= %F + %Fj \n\r", i, creal(target_arm[i]), cimag(target_arm[i]));
  // }
  // for(unsigned i = 0; i < problemSize; i++) {
  //   printf("target_fgpu[%d]= %F + %Fj \n\r", i, creal(target_fgpu[i]), cimag(target_fgpu[i]));
  // }
  for (i = 0; i < problemSize; i++)
    if(target_arm[i] != target_fgpu[i])
    {
      #if PRINT_ERRORS
      cout << "res[" << i << "]=" << creal(target_fgpu[i]);
      if(cimag(target_fgpu[i]) >= 0)
        cout << "+";
      cout << cimag(target_fgpu[i])<<"j";
      cout << " must be(" << creal(target_arm[i]);
      if(cimag(target_arm[i]) >= 0)
        cout << "+";
      cout << cimag(target_arm[i])<<"j)" << endl;
      #endif
      nErrors++;
    }
  if(nErrors != 0)
    xil_printf("Memory check failed (nErrors = %d)!\n\r", nErrors);
  // else
  //   xil_printf("Succeeded!\n\r");
}
template<typename T>
void kernel<T>::update_and_download()
{
  stageIndx++;
  lram_ptr[17] = stageIndx;
  // Xil_DCacheFlushRange((unsigned)lram_ptr, 32*4);
}
template<typename T>
unsigned kernel<T>::compute_on_FGPU(unsigned n_runs, bool check_results)
{
  unsigned runs = 0;
  XTime tStart, tEnd;
  unsigned exec_time = 0;


  REG_WRITE(INITIATE_REG_ADDR, 0xFFFF); // initiate FGPU when execution starts
  REG_WRITE(CLEAN_CACHE_REG_ADDR, 1); // do not clean FGPU cache at end of execution
  while(runs < n_runs)
  {
    stageIndx = 0;
    download_descriptor();
    memcpy(target_fgpu, param1, dataSize);
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("input[%d]= %F + %Fj \n\r", i, creal(target_fgpu[i]), cimag(target_fgpu[i]));
    // }
    bitReverse(target_fgpu, problemSize, nStages);
    // printf("After bitReverse:\n");
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("input[%d]= %F + %Fj \n\r", i, creal(target_fgpu[i]), cimag(target_fgpu[i]));
    // }
    // printf("Before processing\n");
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("target_fgpu[%d]= %F + %Fj \n\r", i, creal(target_fgpu[i]), cimag(target_fgpu[i]));
    // }
    // for(unsigned i = 0; i < problemSize; i++) {
    //   printf("twiddles[%d]= %F + %Fj \n\r", i, creal(twiddles[i]), cimag(twiddles[i]));
    // }
    // printf("\n");
    Xil_DCacheFlush();
    XTime_GetTime(&tStart);
    
    do
    {
      REG_WRITE(START_REG_ADDR, 1);
      while(REG_READ(STATUS_REG_ADDR)==0);
      update_and_download();
      // Xil_DCacheInvalidate();
      // for(unsigned i = 0; i < problemSize; i++) {
      //   printf("target_fgpu[%d]= %F + %Fj \n\r", i, creal(target_fgpu[i]), cimag(target_fgpu[i]));
      // }
      // printf("\n");
      // REG_WRITE(INITIATE_REG_ADDR, 0); // do not initiate FGPU for next iterations
      // if(stageIndx == nStages-1 && passIndx == nStages-1){
      //   REG_WRITE(CLEAN_CACHE_REG_ADDR, 1); // clean cache for the last iteration
      // }
    }while(stageIndx < nStages);
    
    XTime_GetTime(&tEnd);
    exec_time += elapsed_time_us(tStart, tEnd);
    
    if(check_results)
      check_FGPU_results();

    xil_printf(ANSI_COLOR_GREEN "." ANSI_COLOR_RESET);
    fflush(stdout);
    runs++;

    if(exec_time > 1000000*MAX_MES_TIME_S)// do not execute all required runs if it took too long
      break;
  }
  return exec_time/runs;
}
template<typename T>
void kernel<T>::print_name()
{
  xil_printf("\n\r" ANSI_COLOR_YELLOW "Kernel is fft");
  if(use_hard_float)
    xil_printf(" (hard)\n\r" ANSI_COLOR_RESET);
  else
    xil_printf(" (soft)\n\r" ANSI_COLOR_RESET);
}

template class kernel<float complex>;
