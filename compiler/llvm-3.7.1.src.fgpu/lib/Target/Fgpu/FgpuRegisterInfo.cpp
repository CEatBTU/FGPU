//===-- FgpuRegisterInfo.cpp - FGPU Register Information -== --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the FGPU implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "fgpu-reg-info"

#include "FgpuRegisterInfo.h"

#include "Fgpu.h"
#include "FgpuSubtarget.h"
#include "FgpuMachineFunction.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define GET_REGINFO_TARGET_DESC
#include "FgpuGenRegisterInfo.inc"

using namespace llvm;

FgpuRegisterInfo::FgpuRegisterInfo(const FgpuSubtarget &ST)
  : FgpuGenRegisterInfo(Fgpu::LR), Subtarget(ST) {}


//===----------------------------------------------------------------------===//
// Callee Saved Registers methods
//===----------------------------------------------------------------------===//
/// Fgpu Callee Saved Registers
// In FgpuCallConv.td,
const uint16_t* FgpuRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  // return NULL;
  return CSR_CC_Fgpu_SaveList;
}

const uint32_t* FgpuRegisterInfo::getCallPreservedMask(const MachineFunction &MF, CallingConv::ID) const {
  // return NULL;
  return CSR_CC_Fgpu_RegMask; 
}

// pure virtual method
BitVector FgpuRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  static const uint16_t ReservedCPURegs[] = {
    Fgpu::R0, Fgpu::SP, Fgpu::LR
  };
  BitVector Reserved(getNumRegs());

  for (unsigned I = 0; I < array_lengthof(ReservedCPURegs); ++I)
    Reserved.set(ReservedCPURegs[I]);

  return Reserved;
}

//- If no eliminateFrameIndex(), it will hang on run. 
// pure virtual method
// FrameIndex represent objects inside a abstract stack.
// We must replace FrameIndex with an stack/frame pointer
// direct reference.
void FgpuRegisterInfo::
eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                    unsigned FIOperandNum, RegScavenger *RS) const {

  DEBUG(dbgs() << "soubhi: eliminateFrameIndex entered" << "\n");
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  unsigned i = 0;
  while (!MI.getOperand(i).isFI()) {
    ++i;
    assert(i < MI.getNumOperands() &&
           "Instr doesn't have FrameIndex operand!");
  }

  DEBUG(dbgs() << "\nFunction : " << MF.getFunction()->getName() << "\n";
        dbgs() << "<--------->\n" << MI);

  int FrameIndex = MI.getOperand(i).getIndex();
  uint64_t stackSize = MF.getFrameInfo()->getStackSize();
  int64_t spOffset = MF.getFrameInfo()->getObjectOffset(FrameIndex);

  DEBUG(dbgs() << "FrameIndex : " << FrameIndex << "\n"
               << "spOffset   : " << spOffset << "\n"
               << "stackSize  : " << stackSize << "\n");

  unsigned FrameReg;

  FrameReg = Fgpu::SP;

  // Calculate final offset.
  // - There is no need to change the offset if the frame object is one of the
  //   following: an outgoing argument, pointer to a dynamically allocated
  //   stack space or a $gp restore location,
  // - If the frame object is any of the following, its offset must be adjusted
  //   by adding the size of the stack:
  //   incoming argument, callee-saved register location or local variable.
  int64_t Offset;
  Offset = spOffset + (int64_t)stackSize;

  Offset    += MI.getOperand(i+1).getImm();

  DEBUG(dbgs() << "Offset     : " << Offset << "\n" << "<--------->\n");

  // If MI is not a debug value, make sure Offset fits in the 16-bit immediate
  // field.
  if (!MI.isDebugValue() && !isInt<16>(Offset)) {
        assert("(!MI.isDebugValue() && !isInt<16>(Offset))");
  }
  // const FgpuSEInstrInfo &TII =
  //     *static_cast<const FgpuSEInstrInfo*>(Subtarget.getInstrInfo());
  
  auto &FgpuST = static_cast<const FgpuSubtarget&>(MF.getSubtarget());
  auto &FgpuII = *FgpuST.getInstrInfo();
  if ( MI.getOpcode() == Fgpu::LW){
    DEBUG(dbgs() << "soubhi: It is a LW\n");
    MI.setDesc(FgpuII.get(Fgpu::LLWI));
  }
  if ( MI.getOpcode() == Fgpu::SW){
    DEBUG(dbgs() << "soubhi: It is a SW\n");
    MI.setDesc(FgpuII.get(Fgpu::LSWI));
  }
  MI.getOperand(i).ChangeToRegister(FrameReg, false);
  MI.getOperand(i+1).ChangeToImmediate(Offset);
  DEBUG(dbgs() << "soubhi: eliminateFrameIndex exiting\n");
}

bool
FgpuRegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
  return true;
}

bool
FgpuRegisterInfo::trackLivenessAfterRegAlloc(const MachineFunction &MF) const {
  return true;
}

// pure virtual method
unsigned FgpuRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return (Fgpu::SP);
}
