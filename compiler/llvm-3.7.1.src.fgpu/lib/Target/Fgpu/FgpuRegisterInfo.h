//===-- FgpuRegisterInfo.h - Fgpu Register Information Impl -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUREGISTERINFO_H
#define FGPUREGISTERINFO_H

#include "Fgpu.h"
#include "llvm/Target/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "FgpuGenRegisterInfo.inc"

namespace llvm {
class FgpuSubtarget;
class TargetInstrInfo;
class Type;

class FgpuRegisterInfo : public FgpuGenRegisterInfo {
protected:
  const FgpuSubtarget &Subtarget;

public:
  FgpuRegisterInfo(const FgpuSubtarget &Subtarget);

  const MCPhysReg *
  getCalleeSavedRegs(const MachineFunction *MF = nullptr) const override;
  const uint32_t *getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID) const override;


  BitVector getReservedRegs(const MachineFunction &MF) const override;

  bool requiresRegisterScavenging(const MachineFunction &MF) const override;

  bool trackLivenessAfterRegAlloc(const MachineFunction &MF) const override;

  /// Stack Frame Processing Methods
  void eliminateFrameIndex(MachineBasicBlock::iterator II,
                           int SPAdj, unsigned FIOperandNum,
                           RegScavenger *RS = nullptr) const override;

  /// Debug information queries.
  unsigned getFrameRegister(const MachineFunction &MF) const override;

  /// \brief Return GPR register class.
  virtual const TargetRegisterClass *intRegClass(unsigned Size) const = 0;
};

} // end namespace llvm

#endif
