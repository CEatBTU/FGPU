//===-- FgpuISEISelLowering.h - FgpuISE DAG Lowering Interface ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of FgpuITargetLowering specialized fgpu
//
//===----------------------------------------------------------------------===//

#ifndef FGPUSEISELLOWERING_H
#define FGPUSEISELLOWERING_H


#include "FgpuISelLowering.h"
#include "FgpuRegisterInfo.h"

namespace llvm {
  class FgpuSETargetLowering : public FgpuTargetLowering  {
  public:
    explicit FgpuSETargetLowering(const FgpuTargetMachine &TM,
                                  const FgpuSubtarget &STI);

    SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;
  };
}

#endif
