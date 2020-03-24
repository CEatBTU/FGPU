//===-- FgpuMCAsmInfo.h - Fgpu Asm Info ------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the FgpuMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUTARGETASMINFO_H
#define FGPUTARGETASMINFO_H


#include "llvm/MC/MCAsmInfo.h"

namespace llvm {
  class Triple;
  class Target;

  class FgpuMCAsmInfo : public MCAsmInfo {
    virtual void anchor();
  public:
    explicit FgpuMCAsmInfo(const Triple &TheTriple);
  };

} // namespace llvm

#endif
