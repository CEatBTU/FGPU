#include "aux_functions.hpp"
using namespace std;

#define TYPE  float

int main()
{
  // The correctness of all results will be checked at the end of each execution round
  const unsigned check_results = 1; 
  // The kernel will be executed for problem sizes of 8*8, 16*16, ... 
  const unsigned test_vec_len = 7;
  // Executions & time measurements will be repeated nruns times 
  const unsigned nruns = 10;
  // control power measurement
  const unsigned sync_power_measurement = 1;
  
  if(check_results)
    xil_printf("\n\r---Entering main (checking FGPU results is" ANSI_COLOR_GREEN" active" ANSI_COLOR_RESET ") ---\n\r");
  else
    xil_printf("\n\r---Entering main (checking FGPU results is" ANSI_COLOR_RED" inactive" ANSI_COLOR_RESET ") ---\n\r");
  


  unsigned i, size_index;

  unsigned *timer_val_fgpu = new unsigned[test_vec_len]();
  unsigned *timer_val_arm = new unsigned[test_vec_len]();

  // enable ARM caches
  Xil_ICacheEnable();
  Xil_DCacheEnable();
  // create kernel
  unsigned maxDim = 8<<test_vec_len;
  kernel<TYPE> floydwarshall_kernel(maxDim);
  power_measure power;
  if( sync_power_measurement ) {
    power.set_idle();
  }
  // download binary to FGPU
  floydwarshall_kernel.download_code();


  floydwarshall_kernel.print_name();
  xil_printf("Problem Sizes :\n\r");

  if( sync_power_measurement ) {
    power.start();
  }
  for(size_index = 0; size_index < test_vec_len; size_index++)
  {
    // initiate the kernel descriptor for the required problem size
    floydwarshall_kernel.prepare_descriptor(8 << size_index);
    xil_printf("%-8u", floydwarshall_kernel.get_problemSize());
    fflush(stdout);

    // break if the requested problem size is set too big by mistake
    if(floydwarshall_kernel.get_problemSize() > MAX_PROBLEM_SIZE){
      xil_printf("Problem size exceeds limit!\n\r");
      break;
    }

    // compute on ARM
    if (!sync_power_measurement ) {
      timer_val_arm[size_index] = floydwarshall_kernel.compute_on_ARM(nruns);
    }
    
    // compute on FGPU
    if (!sync_power_measurement ) 
      timer_val_fgpu[size_index] = floydwarshall_kernel.compute_on_FGPU(nruns, check_results);
    else
      timer_val_fgpu[size_index] = floydwarshall_kernel.compute_on_FGPU(nruns, false);

    xil_printf("\n\r");

  }
  if( sync_power_measurement ) {
    power.stop();
  }

  // print execution times
  cout<<endl<<left<<setw(20)<<"Problem Size"<<setw(25)<<"Execution Time (us)"<<setw(25)<<           "Execution Time (us)"<<setw(25)<<"Speedup"<< endl;
  cout<<setw(32)<<ANSI_COLOR_GREEN  <<                  "FGPU"<<setw(27)<<ANSI_COLOR_RED<<setw(10)<<"ARM"<< ANSI_COLOR_RESET <<endl;
  for(i = 0; i < size_index; i++)
    cout<<setw(28) << (8<<i)*(8<<i) <<
      setw(25) << timer_val_fgpu[i] <<
      setw(18) << timer_val_arm[i] <<
      setw(20)<< fixed << setprecision(2) << ((float)timer_val_arm[i]/(float)timer_val_fgpu[i])<<endl;
  
  if( sync_power_measurement ) {
    power.wait_power_values();
    power.print_values();
  }

  xil_printf("---Exiting main---\n\r");
  fflush(stdout);

  delete[] timer_val_fgpu;
  delete[] timer_val_arm;

  return 0;
}


