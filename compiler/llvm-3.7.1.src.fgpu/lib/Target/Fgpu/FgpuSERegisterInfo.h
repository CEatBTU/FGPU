//===-- FgpuSERegisterInfo.h - Fgpu32 Register Information ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu32/64 implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUSEREGISTERINFO_H
#define FGPUSEREGISTERINFO_H

#include "FgpuRegisterInfo.h"

namespace llvm {
class FgpuSEInstrInfo;

class FgpuSERegisterInfo : public FgpuRegisterInfo {
public:
  FgpuSERegisterInfo(const FgpuSubtarget &Subtarget);

  const TargetRegisterClass *intRegClass(unsigned Size) const override;
};

} // end namespace llvm

#endif
