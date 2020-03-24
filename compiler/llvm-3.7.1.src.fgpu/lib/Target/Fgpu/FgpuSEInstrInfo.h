//===-- FgpuSEInstrInfo.h - Fgpu32/64 Instruction Information ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu32/64 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUSEINSTRUCTIONINFO_H
#define FGPUSEINSTRUCTIONINFO_H


#include "FgpuInstrInfo.h"
#include "FgpuSERegisterInfo.h"
#include "FgpuMachineFunction.h"

namespace llvm {

class FgpuSEInstrInfo : public FgpuInstrInfo {
  const FgpuSERegisterInfo RI;

public:
  explicit FgpuSEInstrInfo(const FgpuSubtarget &STI);

  const FgpuRegisterInfo &getRegisterInfo() const override;

  void copyPhysReg(MachineBasicBlock &MBB,
                   MachineBasicBlock::iterator MI, DebugLoc DL,
                   unsigned DestReg, unsigned SrcReg,
                   bool KillSrc) const override;

  void storeRegToStack(MachineBasicBlock &MBB,
                       MachineBasicBlock::iterator MI,
                       unsigned SrcReg, bool isKill, int FrameIndex,
                       const TargetRegisterClass *RC,
                       const TargetRegisterInfo *TRI,
                       int64_t Offset) const override;

  void loadRegFromStack(MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MI,
                        unsigned DestReg, int FrameIndex,
                        const TargetRegisterClass *RC,
                        const TargetRegisterInfo *TRI,
                        int64_t Offset) const override;

  bool expandPostRAPseudo(MachineBasicBlock::iterator MI) const override;

  /// Adjust SP by Amount bytes.
  void adjustStackPtr(unsigned SP, int64_t Amount, MachineBasicBlock &MBB,
                      MachineBasicBlock::iterator I) const override;

private:
  void ExpandRetLR(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                   unsigned Opc) const;
  void ExpandLi32(MachineBasicBlock &MBB, MachineBasicBlock::iterator &I) const;
};

}


#endif
