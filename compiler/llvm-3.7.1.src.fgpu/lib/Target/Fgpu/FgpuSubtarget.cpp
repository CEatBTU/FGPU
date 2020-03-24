//===-- FgpuSubtarget.cpp - Fgpu Subtarget Information --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Fgpu specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "FgpuSubtarget.h"

#include "FgpuMachineFunction.h"
#include "Fgpu.h"
#include "FgpuRegisterInfo.h"

#include "FgpuTargetMachine.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "FgpuGenSubtargetInfo.inc"



extern bool FixGlobalBaseReg;

/// Select the Fgpu CPU for the given triple and cpu name.
/// FIXME: Merge with the copy in FgpuMCTargetDesc.cpp
static StringRef selectFgpuCPU(Triple TT, StringRef CPU) {
  if (CPU.empty() || CPU == "generic") {
    if (TT.getArch() == Triple::fgpu)
      CPU = "fgpu32";
  }
  return CPU;
}

void FgpuSubtarget::anchor() { }

//@1 {
FgpuSubtarget::FgpuSubtarget(const Triple &TT, const std::string &CPU,
                             const std::string &FS, bool little, 
                             const FgpuTargetMachine &_TM) :
//@1 }
  // FgpuGenSubtargetInfo will display features by llc -march=fgpu -mcpu=help
  FgpuGenSubtargetInfo(TT, CPU, FS),
  TM(_TM), TargetTriple(TT), TSInfo(),
      InstrInfo(
          FgpuInstrInfo::create(initializeSubtargetDependencies(CPU, FS, TM))),
      FrameLowering(FgpuFrameLowering::create(*this)),
      TLInfo(FgpuTargetLowering::create(TM, *this)) {

}

FgpuSubtarget &
FgpuSubtarget::initializeSubtargetDependencies(StringRef CPU, StringRef FS,
                                               const TargetMachine &TM) {
  std::string CPUName = selectFgpuCPU(TargetTriple, CPU);

  if (CPUName == "help")
    CPUName = "fgpu32";
  
  if (CPUName == "fgpu32")
    FgpuArchVersion = Fgpu32;


  // Parse features string.
  ParseSubtargetFeatures(CPUName, FS);
  // Initialize scheduling itinerary for the specified CPU.
  InstrItins = getInstrItineraryForCPU(CPUName);

  return *this;
}

