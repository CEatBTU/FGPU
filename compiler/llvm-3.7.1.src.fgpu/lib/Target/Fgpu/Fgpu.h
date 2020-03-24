//===-- Fgpu.h - Top-level interface for Fgpu representation ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in
// the LLVM Fgpu back-end.
//
//===----------------------------------------------------------------------===//

#ifndef TARGET_FGPU_H
#define TARGET_FGPU_H

#include "MCTargetDesc/FgpuMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
  class FgpuTargetMachine;
  class FunctionPass;

  FunctionPass *createFgpuDelBranchPass(FgpuTargetMachine &TM);

} // end namespace llvm;

#endif
