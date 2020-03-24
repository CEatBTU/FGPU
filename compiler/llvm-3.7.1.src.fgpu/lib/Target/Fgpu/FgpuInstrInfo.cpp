//===-- FgpuInstrInfo.cpp - Fgpu Instruction Information ------------------===//
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

#include "FgpuInstrInfo.h"

#include "FgpuTargetMachine.h"
#include "FgpuMachineFunction.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-instr-info"

#define GET_INSTRINFO_CTOR_DTOR
#include "FgpuGenInstrInfo.inc"

// Pin the vtable to this file.
void FgpuInstrInfo::anchor() {}

//@FgpuInstrInfo {
FgpuInstrInfo::FgpuInstrInfo(const FgpuSubtarget &STI): 
      FgpuGenInstrInfo(Fgpu::ADJCALLSTACKDOWN, Fgpu::ADJCALLSTACKUP),
      Subtarget(STI) {}

const FgpuInstrInfo *FgpuInstrInfo::create(FgpuSubtarget &STI) {
  return llvm::createFgpuSEInstrInfo(STI);
}


void
FgpuInstrInfo::BuildUncondBr(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                           DebugLoc DL) const {
  unsigned Opc = Fgpu::BEQ;
  const MCInstrDesc &MCID = get(Opc);
  MachineInstrBuilder MIB = BuildMI(&MBB, DL, MCID);

  MIB.addReg(Fgpu::R0);
  MIB.addReg(Fgpu::R0);
  MIB.addMBB(TBB);
}

void
FgpuInstrInfo::BuildCondBr(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                           DebugLoc DL, ArrayRef<MachineOperand> Cond) const {
  DEBUG(dbgs()<<"soubhi: BuildCondBr is entered\n");
  unsigned Opc = Cond[0].getImm();
  const MCInstrDesc &MCID = get(Opc);
  MachineInstrBuilder MIB = BuildMI(&MBB, DL, MCID);

  for (unsigned i = 1; i < Cond.size(); ++i) {
    if (Cond[i].isReg())
    {
      DEBUG(dbgs()<<"soubhi: Cond["<<i<<"] is register\n");
      MIB.addReg(Cond[i].getReg());
    }
    else if (Cond[i].isImm())
    {
      DEBUG(dbgs()<<"soubhi: Cond["<<i<<"] is immediate\n");
      MIB.addImm(Cond[i].getImm());
    }
    else
       assert(true && "Cannot copy operand");
  }
  MIB.addMBB(TBB);
}

unsigned FgpuInstrInfo::InsertBranch(
    MachineBasicBlock &MBB, MachineBasicBlock *TBB, MachineBasicBlock *FBB,
    ArrayRef<MachineOperand> Cond, DebugLoc DL) const {
  DEBUG(dbgs() << "soubhi: InsertBranch entered\n");
  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");

  // # of condition operands:
  //  Unconditional branches: 0
  DEBUG(dbgs() << "Cond.size() = " << Cond.size() << "\n");
  assert((Cond.size() <= 3) &&
         "# of Fgpu branch conditions must be <= 3!");

  // Two-way Conditional branch.
  if (FBB) {
    DEBUG(dbgs() << "Two way conditional branch\n");
    BuildCondBr(MBB, TBB, DL, Cond);
    BuildUncondBr(MBB, FBB, DL);
    return 2;
  }

  // One way branch.
  // Unconditional branch.
  if (Cond.empty())
    BuildUncondBr(MBB, TBB, DL);
  else // Conditional branch.
    BuildCondBr(MBB, TBB, DL, Cond);
  return 1;
}

