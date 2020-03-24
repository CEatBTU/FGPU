//===-- FgpuDelUselessBranch.cpp - Fgpu DelBranch -------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Simple pass to fills delay slots with useful instructions.
//
//===----------------------------------------------------------------------===//

#include "Fgpu.h"
#include "FgpuTargetMachine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Support/Debug.h"


using namespace llvm;

#define DEBUG_TYPE "del-branch"

STATISTIC(NumDelBranch, "Number of useless branch deleted");

static cl::opt<bool> EnableDelBranch(
  "enable-fgpu-del-useless-branch",
  cl::init(true),
  cl::desc("Delete useless branch instructions: beq r0, r0, 0."),
  cl::Hidden);

namespace {
  struct DelBranch : public MachineFunctionPass {
    static char ID;
    DelBranch(TargetMachine &tm) : MachineFunctionPass(ID) { }
    virtual const char *getPassName() const {
      return "Fgpu Del Useless branch";
    }
    bool runOnMachineBasicBlock(MachineBasicBlock &MBB, MachineBasicBlock &MBBN);
    bool runOnMachineFunction(MachineFunction &F);

  };
  char DelBranch::ID = 0;
} 
bool DelBranch::runOnMachineFunction(MachineFunction &F) {
  DEBUG(dbgs() << "soubhi: delBranch on Function pass entered\n");
    bool Changed = false;
    if (EnableDelBranch) {
      MachineFunction::iterator FJ = F.begin();
    if (FJ != F.end())
      FJ++;
    if (FJ == F.end())
      return Changed;
    for (MachineFunction::iterator FI = F.begin(), FE = F.end();
        FJ != FE;
        ++FI, ++FJ)
    // In STL style, F.end() is the dummy BasicBlock() like '\0' in 
    //  C string. 
    // FJ is the next BasicBlock of FI; When FI range from F.begin() to 
    //  the PreviousBasicBlock of F.end() call runOnMachineBasicBlock().
    Changed |= runOnMachineBasicBlock(*FI, *FJ);
  }
  return Changed;
}

bool DelBranch::runOnMachineBasicBlock(MachineBasicBlock &MBB, MachineBasicBlock &MBBN) {
  DEBUG(dbgs() << "soubhi: delBranch on basic block pass entered\n");
  bool Changed = false;

  MachineBasicBlock::iterator I = MBB.end();
  if (I != MBB.begin())
    I--;	// set I to the last instruction
  else
    return Changed;
    
  if ( (I->getOpcode() == Fgpu::BEQ || I->getOpcode() == Fgpu::BNE) && I->getOperand(2).getMBB() == &MBBN) {
    // I is the instruction of "beq rx, rx, #offset=0", as follows,
    //     beq r0, r0,	$BB0_3
    // $BB0_3:
    //     add	r1, r1, r2
    ++NumDelBranch;
    MBB.erase(I);	// delete the "beq r0, r0, 0" instruction
    Changed = true;	// Notify LLVM kernel Changed
  }
  return Changed;

}

/// createFgpuDelBranchPass - Returns a pass that DelBranch in Fgpu MachineFunctions
FunctionPass *llvm::createFgpuDelBranchPass(FgpuTargetMachine &tm) {
  return new DelBranch(tm);
}

