//===-- FgpuFrameLowering.h - Define frame lowering for Fgpu ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//
//===----------------------------------------------------------------------===//
#ifndef FGPU_FRAMEINFO_H
#define FGPU_FRAMEINFO_H

#include "Fgpu.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"

namespace llvm {
  class FgpuSubtarget;

class FgpuFrameLowering : public TargetFrameLowering {
protected:
  const FgpuSubtarget &STI;

public:
  explicit FgpuFrameLowering(const FgpuSubtarget &sti, unsigned Alignment)
    : TargetFrameLowering(StackGrowsDown, Alignment, 0, Alignment), STI(sti) {
  }

  static const FgpuFrameLowering *create(const FgpuSubtarget &ST);

  void eliminateCallFramePseudoInstr(MachineFunction &MF,
                                  MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator I) const override;
  bool hasFP(const MachineFunction &MF) const override;

};

/// Create FgpuFrameLowering objects.
const FgpuFrameLowering *createFgpuSEFrameLowering(const FgpuSubtarget &ST);

} // End llvm namespace

#endif
