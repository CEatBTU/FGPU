//===-- FgpuSEInstrInfo.cpp - Fgpu32/64 Instruction Information -----------===//
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

#include "FgpuSEInstrInfo.h"

#include "FgpuMachineFunction.h"
#include "FgpuTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "fgpu-isel"
using namespace llvm;

static MachineMemOperand* GetMemOperand(MachineBasicBlock &MBB, int FI,
                                        unsigned Flag) {
  MachineFunction &MF = *MBB.getParent();
  MachineFrameInfo &MFI = *MF.getFrameInfo();
  unsigned Align = MFI.getObjectAlignment(FI);

  return MF.getMachineMemOperand(MachinePointerInfo::getFixedStack(FI), Flag,
                                 MFI.getObjectSize(FI), Align);
}

FgpuSEInstrInfo::FgpuSEInstrInfo(const FgpuSubtarget &STI)
    : FgpuInstrInfo(STI),
      RI(STI) {}

const FgpuRegisterInfo &FgpuSEInstrInfo::getRegisterInfo() const {
  return RI;
}

void FgpuSEInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
            MachineBasicBlock::iterator I, DebugLoc DL,
            unsigned DestReg, unsigned SrcReg,
            bool KillSrc) const {
  
  MachineInstrBuilder MIB = BuildMI(MBB, I, DL, get(Fgpu::ADD));

  if (DestReg)
    MIB.addReg(DestReg, RegState::Define);

  MIB.addReg(Fgpu::R0);

  if (SrcReg)
    MIB.addReg(SrcReg, getKillRegState(KillSrc));
}

void FgpuSEInstrInfo::storeRegToStack(MachineBasicBlock &MBB,
                MachineBasicBlock::iterator I,
                unsigned SrcReg, bool isKill, int FI,
                const TargetRegisterClass *RC, const TargetRegisterInfo *TRI,
                int64_t Offset) const {
  DEBUG(dbgs() << "storeRegOnStack entered!\n");
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);

  unsigned Opc = 0;

  Opc = Fgpu::SW;
  assert(Opc && "Register class not handled!");
  BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
    .addFrameIndex(FI).addImm(0).addMemOperand(MMO);
}

void FgpuSEInstrInfo::
loadRegFromStack(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                 unsigned DestReg, int FI, const TargetRegisterClass *RC,
                 const TargetRegisterInfo *TRI, int64_t Offset) const {
  DEBUG(dbgs() << "loadRegFromStack entered!\n");
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
  unsigned Opc = 0;

  Opc = Fgpu::LW;
  assert(Opc && "Register class not handled!");
  BuildMI(MBB, I, DL, get(Opc), DestReg).addFrameIndex(FI).addImm(Offset)
    .addMemOperand(MMO);
}

// FgpuSEInstrInfo::expandPostRAPseudo
/// Expand Pseudo instructions into real backend instructions
bool FgpuSEInstrInfo::expandPostRAPseudo(MachineBasicBlock::iterator MI) const {
  MachineBasicBlock &MBB = *MI->getParent();
  // DEBUG(errs() << "soubhi: entering expandPostRAPseudo\n");

  switch(MI->getDesc().getOpcode()) {
  default:
    return false;
  case Fgpu::RetLR:
    ExpandRetLR(MBB, MI, Fgpu::RET);
    break;
  case Fgpu::Li32:
    ExpandLi32(MBB, MI);
    break;
  }

  MBB.erase(MI);
  return true;
}

void FgpuSEInstrInfo::ExpandLi32(MachineBasicBlock &MBB, MachineBasicBlock::iterator &I) const {
  unsigned DstReg = I->getOperand(0).getReg();
  const MachineOperand &MO = I->getOperand(1);
  unsigned ImmVal = (unsigned)MO.getImm();
  BuildMI(MBB, I, I->getDebugLoc(), get(Fgpu::Li), DstReg).addImm(ImmVal);
  BuildMI(MBB, I, I->getDebugLoc(), get(Fgpu::LUi), DstReg).addImm(ImmVal>>16);
}
/// Adjust SP by Amount bytes.
void FgpuSEInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
                                     MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I) const {
  DEBUG(dbgs() << "Required entries on stack = " << -Amount/4 << "\n");
  DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
  unsigned ADDi = Fgpu::ADDi;

  if (isInt<14>(Amount)) {
    // assert(-Amount/4 <= 32 && "Only 32 registers can be stored on the stack");
    // addi sp, sp, amount
    BuildMI(MBB, I, DL, get(ADDi), SP).addReg(SP).addImm(Amount/4);
  }
  else { // Expand immediate that doesn't fit in 14-bit.
    assert(0);
  }
}


void FgpuSEInstrInfo::ExpandRetLR(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I,
                                unsigned Opc) const {
  BuildMI(MBB, I, I->getDebugLoc(), get(Opc));
}

const FgpuInstrInfo *llvm::createFgpuSEInstrInfo(const FgpuSubtarget &STI) {
  return new FgpuSEInstrInfo(STI);
}

