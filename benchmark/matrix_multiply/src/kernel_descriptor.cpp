#include "kernel_descriptor.hpp"

extern unsigned *code; // binary storde in code.c as an array
extern unsigned *code_hard_float; // binary storde in code_hard_float.c as an array

template<typename T>
kernel<T>::kernel(unsigned maxDim, bool vector_types, bool hard_float)
{
  param1 = new T[maxDim*maxDim];
  param2 = new T[maxDim*maxDim];
  target_fgpu = new T[maxDim*maxDim];
  target_arm = new T[maxDim*maxDim];
  use_vector_types = vector_types;
  use_hard_float = hard_float;
}
template<typename T>
kernel<T>::~kernel() 
{
  delete[] param1;
  delete[] param2;
  delete[] target_fgpu;
  delete[] target_arm;
}
template<typename T>
void kernel<T>::download_code()
{
  volatile unsigned *cram_ptr = (unsigned *)(FGPU_BASEADDR+ 0x4000);
  unsigned int size = MATRIX_MULTIPLY_LEN;
  unsigned *code_ptr = code;
  if (typeid(T) == typeid(float)) {
    if(use_hard_float) {
      start_addr = MATRIX_MULTIPLY_HARD_FLOAT_POS;
      size = MATRIX_MULTIPLY_HARD_FLOAT_LEN;
      code_ptr = code_hard_float;
    } else {
      start_addr = MATRIX_MULTIPLY_FLOAT_POS;
    }
  }
  else if (typeid(T) == typeid(int))
    start_addr = MATRIX_MULTIPLY_POS;
  else if (typeid(T) == typeid(short)) 
    if(use_vector_types)
      start_addr = MATRIX_MULTIPLY_HALF_IMPROVED_POS;
    else
      start_addr = MATRIX_MULTIPLY_HALF_POS;
  else if (typeid(T) == typeid(char))
    if(use_vector_types)
      start_addr = MATRIX_MULTIPLY_BYTE_IMPROVED_POS;
    else
      start_addr = MATRIX_MULTIPLY_BYTE_POS;
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
  volatile unsigned* lram_ptr = (unsigned*)FGPU_BASEADDR;
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
  lram_ptr[16] = (unsigned) param1;
  lram_ptr[17] = (unsigned) param2;
  lram_ptr[18] = (unsigned) target_fgpu;
}
template<typename T>
void kernel<T>::prepare_descriptor(unsigned int Size)
{
  wg_size0 = 8;
  wg_size1 = 8;
  problemSize = Size*Size;
  offset0 = 0;
  offset1 = 0;
  nDim = 2;
  size0 = Size;
  size1 = Size;
  dataSize = sizeof(T)*problemSize;

  if(size0 < 8)
    wg_size0 = size0;
  if(size1 < 8)
    wg_size1 = size1;

  compute_descriptor();

  offset0 = offset1 = offset2 = 0;
  nParams = 3; // number of parameters
}
template<typename T>
void kernel<T>::initialize_memory()
{
  unsigned i;
  T *param1_ptr = (T*) param1;
  T *param2_ptr = (T*) param2;
  T *target_ptr = (T*) target_fgpu;
  for(i = 0; i < problemSize; i++) 
  {
    param2_ptr[i] = (T)i;
    param1_ptr[i] = (T)i;
    target_ptr[i] = 0;
  }
  Xil_DCacheFlush(); // flush data to global memory
}
template<typename T>
void matrix_multiply(T *out, T *in1, T *in2, unsigned Size) 
{
  for(unsigned i = 0; i < Size; i++) {
    for(unsigned j = 0; j < Size; j++) {
      T res = 0;
      for(unsigned k = 0; k < Size; k++) {
        res += in1[i*Size + k]*in2[k*Size+j];
      }
      out[i*Size + j] = res;
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
    Xil_DCacheFlush();
    Xil_DCacheInvalidate();

    XTime_GetTime(&tStart);
    matrix_multiply(target_arm, param1, param2, size0);
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
  unsigned i, nErrors = 0;
  
  for (i = 0; i < problemSize; i++)
    if(target_arm[i] != target_fgpu[i])
    {
      #if PRINT_ERRORS
      if( typeid(T) == typeid(int) ) {
          xil_printf("res[%d]=%6.2f (must be %6.2f)\n\r", i, (float)target_fgpu[i], (float) target_arm[i]);
      } else {
          xil_printf("res[0x%x]=0x%x (must be 0x%x)\n\r", i, (unsigned)target_fgpu[i], (unsigned) target_arm[i]);
      }
      #endif
      nErrors++;
    }
  if(nErrors != 0) {
    xil_printf("Memory check failed (nErrors = %d)!\n\r", nErrors);
      if( typeid(T) != typeid(int) )
        xil_printf("WARNING: Overflow may cause some mismatch between ARM and FGPU results\n");
    }
}
template<typename T>
unsigned kernel<T>::compute_on_FGPU(unsigned n_runs, bool check_results)
{
  unsigned runs = 0;
  XTime tStart, tEnd;
  unsigned exec_time = 0;

  while(runs < n_runs)
  {
    initialize_memory();
    download_descriptor();
    REG_WRITE(INITIATE_REG_ADDR, 0xFFFF); // initiate FGPU when execution starts
    REG_WRITE(CLEAN_CACHE_REG_ADDR, 0xFFFF); // clean FGPU cache at end of execution
    
    XTime_GetTime(&tStart);
    REG_WRITE(START_REG_ADDR, 1);
    while(REG_READ(STATUS_REG_ADDR)==0);
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
  if( typeid(T) == typeid(int) )
    xil_printf("\n\r" ANSI_COLOR_YELLOW "Kernel is matrix_multiply word\n\r" ANSI_COLOR_RESET);
  else if (typeid(T) == typeid(short))
    xil_printf("\n\r" ANSI_COLOR_YELLOW "Kernel is matrix_multiply half word\n\r" ANSI_COLOR_RESET);
  else if (typeid(T) == typeid(char))
    xil_printf("\n\r" ANSI_COLOR_YELLOW "Kernel is matrix_multiply byte\n\r" ANSI_COLOR_RESET);
  else if (typeid(T) == typeid(float)) {
    xil_printf("\n\r" ANSI_COLOR_YELLOW "Kernel is matrix_multiply float");
    if(use_hard_float)
      xil_printf(" (hard)\n\r" ANSI_COLOR_RESET);
    else
      xil_printf(" (soft)\n\r" ANSI_COLOR_RESET);
  }
}
template<typename T>
unsigned kernel<T>::get_problemSize() 
{
  return problemSize;
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

template class kernel<float>;
template class kernel<int>;
template class kernel<short>;
template class kernel<char>;
