//===-- FgpuSEFrameLowering.cpp - Fgpu Frame Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "FgpuSEFrameLowering.h"

#include "FgpuAnalyzeImmediate.h"
#include "FgpuMachineFunction.h"
#include "FgpuSEInstrInfo.h"
#include "FgpuSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-frame-lower"

FgpuSEFrameLowering::FgpuSEFrameLowering(const FgpuSubtarget &STI)
    : FgpuFrameLowering(STI, STI.stackAlignment()) {}

//@emitPrologue {
void FgpuSEFrameLowering::emitPrologue(MachineFunction &MF,
                                       MachineBasicBlock &MBB) const {
  DEBUG(dbgs() << "soubhi: emitPrologue entered\n");
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");
  MachineFrameInfo *MFI    = MF.getFrameInfo();

  const FgpuSEInstrInfo &TII =
    *static_cast<const FgpuSEInstrInfo*>(STI.getInstrInfo());

  MachineBasicBlock::iterator MBBI = MBB.begin();
  DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  unsigned SP = Fgpu::SP;

  
  // First, compute final stack size.
  uint64_t StackSize = MFI->getStackSize();
  DEBUG (dbgs() << "soubhi: Needed Stacksize is " << StackSize/4 << " entries\n");

  // No need to allocate space on the stack.
  if (StackSize == 0 && !MFI->adjustsStack()) return;

  MachineModuleInfo &MMI = MF.getMMI();
  const MCRegisterInfo *MRI = MMI.getContext().getRegisterInfo();
  MachineLocation DstML, SrcML;

  // Adjust stack.
  TII.adjustStackPtr(SP, -StackSize, MBB, MBBI);
  
  // releveant to debugging!
  // emit ".cfi_def_cfa_offset StackSize" 
  unsigned CFIIndex = MMI.addFrameInst(
      MCCFIInstruction::createDefCfaOffset(nullptr, -StackSize));
  BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex);

  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();

  if (CSI.size()) {
    // Find the instruction past the last instruction that saves a callee-saved
    // register to the stack.
    for (unsigned i = 0; i < CSI.size(); ++i)
      ++MBBI;

    // Iterate over list of callee-saved registers and emit .cfi_offset
    // directives.
    for (std::vector<CalleeSavedInfo>::const_iterator I = CSI.begin(),
           E = CSI.end(); I != E; ++I) {
      int64_t Offset = MFI->getObjectOffset(I->getFrameIdx());
      unsigned Reg = I->getReg();
      {
        // Reg is in CPURegs.
        unsigned CFIIndex = MMI.addFrameInst(MCCFIInstruction::createOffset(
            nullptr, MRI->getDwarfRegNum(Reg, 1), Offset));
        BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
            .addCFIIndex(CFIIndex);
      }
    }
  }

  DEBUG(dbgs() << "soubhi: emitPrologue exiting\n");
}
//}

//@emitEpilogue {
void FgpuSEFrameLowering::emitEpilogue(MachineFunction &MF,
                                 MachineBasicBlock &MBB) const {
  DEBUG(dbgs() << "soubhi: emitEpilogue entered\n");
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo *MFI            = MF.getFrameInfo();
  // FgpuFunctionInfo *FgpuFI = MF.getInfo<FgpuFunctionInfo>();

  const FgpuSEInstrInfo &TII =
    *static_cast<const FgpuSEInstrInfo*>(MF.getSubtarget().getInstrInfo());

  DebugLoc dl = MBBI->getDebugLoc();
  unsigned SP = Fgpu::SP;


  // Get the number of bytes from FrameInfo
  uint64_t StackSize = MFI->getStackSize();

  if (!StackSize)
    return;

  // Adjust stack.
  TII.adjustStackPtr(SP, StackSize, MBB, MBBI);
  DEBUG(dbgs() << "soubhi: emitEpilogue exits\n");
}
//}

bool FgpuSEFrameLowering::spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MI,
                          const std::vector<CalleeSavedInfo> &CSI,
                          const TargetRegisterInfo *TRI) const {
  DEBUG(dbgs() << "soubhi: spillCalleeSavedRegisters entered\n");
  MachineFunction *MF = MBB.getParent();
  const Function *F = MF->getFunction();
  bool isKernel = isKernelFunction(*F);
  // if a kernel function is called, there is no need to save registers
  if (isKernel){
    DEBUG(dbgs() << "No registers will be saved when calling kernel functions\n");
    return true;
  }
  MachineBasicBlock *EntryBlock = MF->begin();
  const TargetInstrInfo &TII = *MF->getSubtarget().getInstrInfo();

  for (unsigned i = 0, e = CSI.size(); i != e; ++i) {
    unsigned Reg = CSI[i].getReg();
    DEBUG(dbgs() << "Register Nr." << Reg << " will be saved\n");
    EntryBlock->addLiveIn(Reg);
    // Insert the spill to the stack frame.
    bool IsKill = true;
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
    TII.storeRegToStackSlot(*EntryBlock, MI, Reg, IsKill,
                            CSI[i].getFrameIdx(), RC, TRI);
  }

  DEBUG(dbgs() << "soubhi: spillCalleeSavedRegisters exiting\n");
  return true;
}



bool FgpuSEFrameLowering::restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                                          MachineBasicBlock::iterator MI,
                                       const std::vector<CalleeSavedInfo> &CSI,
                                       const TargetRegisterInfo *TRI) const {
  DEBUG(dbgs() << "soubhi: restoreCalleeSavedRegisters entered\n");
  MachineFunction *MF = MBB.getParent();
  const Function *F = MF->getFunction();
  bool isKernel = isKernelFunction(*F);
  // if a kernel function is called, there is no need to restore registers
  if (isKernel){
    DEBUG(dbgs() << "No registers will be restored when finishing a kernel functions\n");
    return true;
  }
  // llvm will restore the registers for non-kernel functions
  DEBUG(dbgs() << "soubhi: restoreCalleeSavedRegisters exiting\n");
  return false;
}


//@hasReservedCallFrame {
bool FgpuSEFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();

  // Reserve call frame if the size of the maximum call frame fits into 14-bit
  // immediate field and there are no variable sized objects on the stack.
  // Make sure the second register scavenger spill slot can be accessed with one
  // instruction.
  return isInt<14>(MFI->getMaxCallFrameSize() + getStackAlignment()) &&
    !MFI->hasVarSizedObjects();
}
//}

// Eliminate ADJCALLSTACKDOWN, ADJCALLSTACKUP pseudo instructions
void FgpuSEFrameLowering::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  DEBUG(dbgs() << "soubhi: eliminateCallFramePseudoInstr entered " << "\n");
      
  // Simply discard ADJCALLSTACKDOWN, ADJCALLSTACKUP instructions.
  MBB.erase(I);
}



//@determineCalleeSaves 
// This method is called immediately before PrologEpilogInserter scans the 
//  physical registers used to determine what callee saved registers should be 
//  spilled. This method is optional. 
void FgpuSEFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                               BitVector &SavedRegs,
                                               RegScavenger *RS) const {
  DEBUG(dbgs() << "soubhi: determineCalleeSaves entered\n");
  const Function *F = MF.getFunction();
  bool isKernel = isKernelFunction(*F);
  // if a kernel function is called, there is no need to save registers
  if (isKernel){
    DEBUG(dbgs() << "soubhi: determineCalleeSaves exiting\n");
    DEBUG(dbgs() << "No registers will be saved when calling kernel functions\n");
    return;
  }
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);



  DEBUG(dbgs() << "soubhi: determineCalleeSaves exiting\n");
  return;
}

const FgpuFrameLowering *
llvm::createFgpuSEFrameLowering(const FgpuSubtarget &ST) {
  return new FgpuSEFrameLowering(ST);
}

