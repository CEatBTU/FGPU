//===-- FgpuMachineFunctionInfo.cpp - Private data used for Fgpu ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "FgpuMachineFunction.h"

#include "FgpuInstrInfo.h"
#include "FgpuSubtarget.h"
#include "llvm/IR/Function.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

bool FixGlobalBaseReg;

// class FgpuCallEntry.
FgpuCallEntry::FgpuCallEntry(const StringRef &N) {
#ifndef NDEBUG
  Name = N;
  Val = nullptr;
#endif
}

FgpuCallEntry::FgpuCallEntry(const GlobalValue *V) {
#ifndef NDEBUG
  Val = V;
#endif
}

bool FgpuCallEntry::isConstant(const MachineFrameInfo *) const {
  return false;
}

bool FgpuCallEntry::isAliased(const MachineFrameInfo *) const {
  return false;
}

bool FgpuCallEntry::mayAlias(const MachineFrameInfo *) const {
  return false;
}

void FgpuCallEntry::printCustom(raw_ostream &O) const {
  O << "FgpuCallEntry: ";
#ifndef NDEBUG
  if (Val)
    O << Val->getName();
  else
    O << Name;
#endif
}

FgpuFunctionInfo::~FgpuFunctionInfo() {
}

void FgpuFunctionInfo::anchor() { }

