//===-- llvm/Target/FgpuTargetObjectFile.h - Fgpu Object Info ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_FGPU_TARGETOBJECTFILE_H
#define LLVM_TARGET_FGPU_TARGETOBJECTFILE_H


#include "FgpuTargetMachine.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
  class FgpuTargetMachine;
  class FgpuTargetObjectFile : public TargetLoweringObjectFileELF {
    MCSection *SmallDataSection;
    MCSection *SmallBSSSection;
    const FgpuTargetMachine *TM;
  public:

    void Initialize(MCContext &Ctx, const TargetMachine &TM) override;

  };
} // end namespace llvm

#endif
