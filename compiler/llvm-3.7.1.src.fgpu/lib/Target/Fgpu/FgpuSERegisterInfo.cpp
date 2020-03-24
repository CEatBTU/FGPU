//===-- FgpuSERegisterInfo.cpp - FGPU Register Information ------== -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the FGPU implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#include "FgpuSERegisterInfo.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-reg-info"

FgpuSERegisterInfo::FgpuSERegisterInfo(const FgpuSubtarget &ST)
  : FgpuRegisterInfo(ST) {}

const TargetRegisterClass *
FgpuSERegisterInfo::intRegClass(unsigned Size) const {
  return &Fgpu::ALURegsRegClass;
}

