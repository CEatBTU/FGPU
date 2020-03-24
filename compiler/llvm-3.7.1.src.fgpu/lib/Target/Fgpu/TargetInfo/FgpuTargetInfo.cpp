//===-- FgpuTargetInfo.cpp - Fgpu Target Implementation -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "Fgpu.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

Target llvm::TheFgpuTarget;

extern "C" void LLVMInitializeFgpuTargetInfo() {
  RegisterTarget<Triple::fgpu,
        /*HasJIT=*/false> X(TheFgpuTarget, "fgpu", "FGPU Soft GPU");
}
