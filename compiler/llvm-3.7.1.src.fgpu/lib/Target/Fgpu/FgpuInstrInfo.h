//===-- FgpuInstrInfo.h - Fgpu Instruction Information ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUINSTRUCTIONINFO_H
#define FGPUINSTRUCTIONINFO_H


#include "Fgpu.h"
#include "FgpuAnalyzeImmediate.h"
#include "FgpuRegisterInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "FgpuGenInstrInfo.inc"

namespace llvm {

class FgpuInstrInfo : public FgpuGenInstrInfo {
  virtual void anchor();
protected:
  const FgpuSubtarget &Subtarget;
public:
  explicit FgpuInstrInfo(const FgpuSubtarget &STI);

  static const FgpuInstrInfo *create(FgpuSubtarget &STI);

  /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
  /// such, whenever a client has an instance of instruction info, it should
  /// always be able to get register info as well (through this method).
  ///
  virtual const FgpuRegisterInfo &getRegisterInfo() const = 0;

  void storeRegToStackSlot(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI,
                           unsigned SrcReg, bool isKill, int FrameIndex,
                           const TargetRegisterClass *RC,
                           const TargetRegisterInfo *TRI) const override {
    storeRegToStack(MBB, MBBI, SrcReg, isKill, FrameIndex, RC, TRI, 0);
  }

  void loadRegFromStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MBBI,
                            unsigned DestReg, int FrameIndex,
                            const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI) const override {
    loadRegFromStack(MBB, MBBI, DestReg, FrameIndex, RC, TRI, 0);
  }

  virtual void storeRegToStack(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MI,
                               unsigned SrcReg, bool isKill, int FrameIndex,
                               const TargetRegisterClass *RC,
                               const TargetRegisterInfo *TRI,
                               int64_t Offset) const = 0;

  virtual void loadRegFromStack(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MI,
                                unsigned DestReg, int FrameIndex,
                                const TargetRegisterClass *RC,
                                const TargetRegisterInfo *TRI,
                                int64_t Offset) const = 0;

  virtual void adjustStackPtr(unsigned SP, int64_t Amount,
                              MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const = 0;

  unsigned InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        DebugLoc DL) const override;
  
  void BuildCondBr(MachineBasicBlock &MBB, MachineBasicBlock *TBB, DebugLoc DL,
                   ArrayRef<MachineOperand> Cond) const;

  void BuildUncondBr(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                           DebugLoc DL) const;
};
const FgpuInstrInfo *createFgpuSEInstrInfo(const FgpuSubtarget &STI);
}

#endif
