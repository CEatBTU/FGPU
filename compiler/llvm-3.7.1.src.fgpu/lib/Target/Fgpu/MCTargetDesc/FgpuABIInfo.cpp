//===---- FgpuABIInfo.cpp - Information about FGPU ABI's ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "FgpuABIInfo.h"
#include "FgpuRegisterInfo.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;


unsigned FgpuABIInfo::GetCalleeAllocdArgSizeInBytes(CallingConv::ID CC) const {
  return CC != 0;
}

FgpuABIInfo FgpuABIInfo::computeTargetABI() {
  FgpuABIInfo abi(ABI::Unknown);

  abi = ABI::CC_Fgpu;
  // Assert exactly one ABI was chosen.
  assert(abi.ThisABI != ABI::Unknown);

  return abi;
}

unsigned FgpuABIInfo::GetStackPtr() const {
  return Fgpu::SP;
}

unsigned FgpuABIInfo::GetNullPtr() const {
  return Fgpu::R0;
}

unsigned FgpuABIInfo::GetEhDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {
    Fgpu::R4, Fgpu::R5, Fgpu::R6, Fgpu::R7
  };

  return EhDataReg[I];
}

