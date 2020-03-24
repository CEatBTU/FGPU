//===-- FgpuSEISelDAGToDAG.cpp - A Dag to Dag Inst Selector for FgpuSE ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of FgpuDAGToDAGISel specialized for fgpu32.
//
//===----------------------------------------------------------------------===//

#include "FgpuSEISelDAGToDAG.h"

#include "MCTargetDesc/FgpuBaseInfo.h"
#include "Fgpu.h"
#include "FgpuMachineFunction.h"
#include "FgpuRegisterInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
using namespace llvm;

#define DEBUG_TYPE "fgpu-isel"

bool FgpuSEDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  DEBUG(dbgs() << "soubhi: FgpuSEDAGToDAGISel pass entered\n");
  Subtarget = &static_cast<const FgpuSubtarget &>(MF.getSubtarget());
  bool ret = FgpuDAGToDAGISel::runOnMachineFunction(MF);
  DEBUG(dbgs() << "soubhi: FgpuSEDAGToDAGISel pass finished\n");
  return ret;
}


bool FgpuSEDAGToDAGISel::replaceUsesWithZeroReg(MachineRegisterInfo *MRI, const MachineInstr& MI) {
  unsigned DstReg = 0, ZeroReg = 0;
  // Check if MI is "addiu $dst, $zero, 0" or "daddiu $dst, $zero, 0".
  if ((MI.getOpcode() == Fgpu::ADDi) &&
      (MI.getOperand(1).getReg() == Fgpu::R0) &&
      (MI.getOperand(2).getImm() == 0)) {
    DstReg = MI.getOperand(0).getReg();
    ZeroReg = Fgpu::R0;
  } 

  if (!DstReg)
    return false;

  // Replace uses with ZeroReg.
  for (MachineRegisterInfo::use_iterator U = MRI->use_begin(DstReg),
       E = MRI->use_end(); U != E;) {
    MachineOperand &MO = *U;
    unsigned OpNo = U.getOperandNo();
    MachineInstr *MI = MO.getParent();
    ++U;

    // Do not replace if it is a phi's operand or is tied to def operand.
    if (MI->isPHI() || MI->isRegTiedToDefOperand(OpNo) || MI->isPseudo())
      continue;

    MO.setReg(ZeroReg);
  }

  return true;
}
void FgpuSEDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {

  MachineRegisterInfo *MRI = &MF.getRegInfo();

  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE; ++MFI)
    for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I) {
      replaceUsesWithZeroReg(MRI, *I);
    }
}


FunctionPass *llvm::createFgpuSEISelDag(FgpuTargetMachine &TM) {
  return new FgpuSEDAGToDAGISel(TM);
}

